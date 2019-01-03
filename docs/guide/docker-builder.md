Docker Builder is a way for Open Source projects to build and publish Docker Images to Docker Registries of their choice.
In essence, a `docker_builder` is basically [a `task`](/guide/writing-tasks.md) that is executed in a VM with pre-installed Docker. 
`docker_builder` can be defined the same way as a `task`:

```yaml
docker_builder:
  build_script: docker build --tag myrepo/foo:latest .
```

Leveraging features like [Task Dependencies](/guide/writing-tasks.md#depepndencies), [Conditional Execution](/guide/writing-tasks.md#conditional-execution)
and [Encrypted Variables](/guide/writing-tasks.md#encrypted-variables) with a Docker Builder can help building some pretty
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
    
### Layer Caching

Docker has `--cache-from` flag which allows to use a previously built image as a cache source. This way only changed
layers will be rebuilt which can drastically improve performance of `build_script`. Here is a snippet that uses 
`--cache-from` flag:

```bash
# pull an image if available
docker pull myrepo/foo:latest || true
docker build --cache-from myrepo/foo:latest \
  --tag myrepo/foo:$CIRRUS_TAG \
  --tag myrepo/foo:latest .
```

### Dockerfile as a CI environment

With Docker Builder there is no need to build and push custom containers so they can be used as an environment to run CI tasks in. 
Cirrus CI can do it for you! Just specify path to a `Dockerfile` via `dockerfile` field for you container 
declaration in `.cirrus.yml` like this:

```yaml
efficient_task:
  container:
    dockerfile: ci/Dockerfile
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

!!! info "Using with private GKE clusters"

    To use `dockerfile` with `gke_container` you first need to create a VM with Docker installed withint your GCP project.
    This image will be used to perform building of Docker images for caching. Once this image is available, for example, by 
    `MY_DOCKER_VM` name, you can simply use it like this:
    
    ```yaml
    gke_container:
      dockerfile: .ci/Dockerfile
      builder_image_name: MY_DOCKER_VM
      cluster_name: cirrus-ci-cluster
      zone: us-central1-a
      namespace: default
    ```
    
    If your builder image is strored in another project. You can also specify it by using `builder_image_project` field.
    By default, Cirrus CI assumes builder image is stored within the same project as the GKE cluster.
