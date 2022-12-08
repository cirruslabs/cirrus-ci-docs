## Docker Builder VM

"Docker Builder" tasks are a way to build and publish Docker Images to Docker Registries of your choice using a VM as build environment.
In essence, a `docker_builder` is basically [a `task`](writing-tasks.md) that is executed in a VM with pre-installed Docker. 
A `docker_builder` can be defined the same way as a `task`:

=== "amd64"

    ```yaml
    docker_builder:
      build_script: docker build --tag myrepo/foo:latest .
    ```

=== "arm64"

    ```yaml
    docker_builder:
      env:
        CIRRUS_ARCH: arm64
      build_script: docker build --tag myrepo/foo:latest .
    ```

Leveraging features such as [Task Dependencies](writing-tasks.md#depepndencies), [Conditional Execution](writing-tasks.md#conditional-execution)
and [Encrypted Variables](writing-tasks.md#encrypted-variables) with a Docker Builder can help building relatively
complex pipelines. It can also be used to execute builds which need special privileges.

In the example below, a `docker_builder` will be only executed on a tag creation, once both `test` and `lint` 
tasks have finished successfully:

```yaml
test_task: ...
lint_task: ...

docker_builder:
  only_if: $CIRRUS_TAG != ''
  depends_on: 
    - test
    - lint
  env:
    DOCKER_USERNAME: ENCRYPTED[...]
    DOCKER_PASSWORD: ENCRYPTED[...]
  build_script: docker build --tag myrepo/foo:$CIRRUS_TAG .
  login_script: docker login --username $DOCKER_USERNAME --password $DOCKER_PASSWORD
  push_script: docker push myrepo/foo:$CIRRUS_TAG
```

!!! info "Example"
    For more examples please check how we use Docker Builder to build and publish Cirrus CI's Docker Images for [Android](https://github.com/cirruslabs/docker-images-android).

### Multi-arch builds

Docker Builder VM has QEMU pre-installed and is able to execute multi-arch builds via [`buildx`](https://docs.docker.com/buildx/working-with-buildx/).
Add the following `setup_script` to enable `buildx` and then use `docker buildx build` instead of the regular `docker build`:

```yaml
docker_builder:
  setup_script:
    - docker buildx create --name multibuilder
    - docker buildx use multibuilder
    - docker buildx inspect --bootstrap
  build_script: docker buildx build --platform linux/amd64,linux/arm64 --tag myrepo/foo:$CIRRUS_TAG .
```

### Pre-installed Packages

For your convenience, a Docker Builder VM has some common packages pre-installed:

* AWS CLI
* Docker Compose
* OpenJDK
* Python
* Ruby with Bundler

### Under the hood

Under the hood a simple integration with [Google Compute Engine](supported-computing-services.md#compute-engine)
is used and basically `docker_builder` is a syntactic sugar for the following [`compute_engine_instance`](custom-vms.md) configuration:

=== "amd64"

    ```yaml
    task:
      compute_engine_instance:
        image_project: cirrus-images
        image: family/docker-builder
        platform: linux
        cpu: 4
        memory: 16G
    ```

=== "arm64"

    ```yaml
    task:
      compute_engine_instance:
        image_project: cirrus-images
        image: family/docker-builder-arm64
        architecture: arm64
        platform: linux
        cpu: 4
        memory: 16G
    ```

You can check Packer templates of the VM image in [`cirruslabs/vm-images` repository](https://github.com/cirruslabs/vm-images).

### Layer Caching

Docker has the `--cache-from` flag which allows using a previously built image as a cache source. This way only changed
layers will be rebuilt which can drastically improve performance of the `build_script`. Here is a snippet that uses 
the `--cache-from` flag:

```bash
# pull an image if available
docker pull myrepo/foo:latest || true
docker build --cache-from myrepo/foo:latest \
  --tag myrepo/foo:$CIRRUS_TAG \
  --tag myrepo/foo:latest .
```

### Dockerfile as a CI environment

With Docker Builder there is no need to build and push custom containers so they can be used as an environment to run CI tasks in. 
Cirrus CI can do it for you! Just declare a path to a `Dockerfile` with the `dockerfile` field for your `container` or `arm_container`
declarations in your `.cirrus.yml` like this:

=== "amd64"

    ```yaml
    efficient_task:
      container:
        dockerfile: ci/Dockerfile
        docker_arguments:
          foo: bar
      test_script: ...
    
    inefficient_task:
      container:
        image: node:latest
      setup_script:
        - apt-get update
        - apt-get install build-essential
      test_script: ...
    ```

=== "arm64"

    ```yaml
    efficient_task:
      arm_container:
        dockerfile: ci/Dockerfile
        docker_arguments:
          foo: bar
      test_script: ...
    
    inefficient_task:
      container:
        image: node:latest
      setup_script:
        - apt-get update
        - apt-get install build-essential
      test_script: ...
    ```

Cirrus CI will build a container and cache the resulting image based on `Dockerfile`’s content. On the next build, 
Cirrus CI will check if a container was already built, and if so, Cirrus CI will instantly start a CI task using the cached image.

Under the hood, for every `Dockerfile` that is needed to be built, Cirrus CI will create a Docker Builder task as a dependency. 
You will see such `build_docker_image_HASH` tasks in the UI.

??? warning "Danger of using `COPY` and `ADD` instructions"
    Cirrus only includes files directly added or copied into a container image in the cache key. But Cirrus is not  recursively 
    waking contents of folders that are being included into the image. This means that for a public repository a potential bad actor 
    can create a PR with malicious scripts included into a container, wait for it to be cached and then reset the PR, so it looks harmless.

    Please try to only `COPY` files by full path, e.g.:

    ```Dockerfile
    FROM python:3
    
    COPY requirements.txt /tmp/
    RUN pip install --requirement /tmp/requirements.txt
    ```

??? info "Using with private GKE clusters"
    To use `dockerfile` with `gke_container` you first need to create a VM with Docker installed within your GCP project.
    This image will be used to perform building of Docker images for caching. Once this image is available, for example, by 
    `MY_DOCKER_VM` name, you can use it like this:
    
    ```yaml
    gke_container:
      dockerfile: .ci/Dockerfile
      builder_image_name: MY_DOCKER_VM
      cluster_name: cirrus-ci-cluster
      zone: us-central1-a
      namespace: default
    ```

    Please make sure your buidler image has [`gcloud` configured as a credential helper](https://cloud.google.com/sdk/gcloud/reference/auth/configure-docker).
    
    If your builder image is stored in another project you can also specify it by using `builder_image_project` field.
    By default, Cirrus CI assumes builder image is stored within the same project as the GKE cluster.

??? info "Using with private EKS clusters"
    To use `dockerfile` with `eks_container` you need three things:

    1. Either create an AMI with Docker installed or use one like [ECS-optimized AMIa](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html). For example, `MY_DOCKER_AMI`.
    2. Create a role which has `AmazonEC2ContainerRegistryFullAccess` policy. For example, `cirrus-builder`.
    3. Create `cirrus-cache` repository in your Elastic Container registry and make sure user that `aws_credentials` are associated with has `ecr:DescribeImages` access to it.

    Once all of the above requirement are met you can configure `eks_container` like this:

    ```yaml
    eks_container:
      region: us-east-2
      cluster_name: my-company-arm-cluster
      dockerfile: .ci/Dockerfile
      builder_image: MY_DOCKER_AMI
      builder_role: cirrus-builder # role for builder instance profile
      builder_instance_type: c7g.xlarge # should match the architecture below
      builder_subnet_id: ... # optional, default subnet from your default VPC is used by default
      architecture: arm64 # default is amd64
    ```

    This will make Cirrus CI to check whether `cirrus-cache` repository in `us-east-2` region contains a precached image
    for `.ci/Dockerfile` of this repository. 

### Windows Support

Docker builders also support building Windows Docker containers - use the `platform` and `os_version` fields:

```yaml
docker_builder:
  platform: windows
  os_version: 2019
  ...
```

!!! tip "Supported OS Versions"
    See [Windows Containers documentation](windows.md#os-versions) for a list of supported OS versions.
