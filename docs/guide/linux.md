## Linux Containers

Linux Community Cluster is a [Kubernetes](https://kubernetes.io/) cluster running on [Google Kubernetes Engine](supported-computing-services.md#google-kubernetes-engine)
that is available free of charge for Open Source community. Paying customers can also use Community Cluster for 
personal private repositories or buy CPU time with [compute credits](../pricing.md#compute-credits) for their private organization repositories.

Community Cluster is configured the same way as anyone can configure a personal GKE cluster as [described here](supported-computing-services.md#google-kubernetes-engine).

By default a container is given 2 CPUs and 4 GB of memory but it can be configured in `.cirrus.yml`:

```yaml
container:
  image: openjdk:8-jdk
  cpu: 4
  memory: 12G

task:
  script: ...
``` 

Containers on Community Cluster can use maximum 8.0 CPUs and up to 24 GB of memory. 

??? warning "Scheduling Times on Community Cluster"
    Since Community Cluster is shared, scheduling times for containers can vary from time to time. Also, the smaller a container 
    require resources the faster it will be scheduled.

??? info "Using in-memory disks"
    Some I/O intensive tasks may benefit from using a `tmpfs` disk mounted as a working directory. Set `use_in_memory_disk` flag
    to enable in-memory disk for a container:
    
    ```yaml
    task:
      name: Much I/O
      container:
        image: alpine:latest
        use_in_memory_disk: true
    ```
    
    **Note**: any files you write including cloned repository will count against your task's memory limit.

??? info "Privileged Access"
    If you need to run privileged docker containers, take a look at the [docker builder](docker-builder-vm.md).
    
### KVM-enabled Privileged Containers

It is possible to run containers with KVM enabled. Some types of CI tasks can tremendously
benefit from native virtualization. For example, Android related tasks can benefit from running hardware accelerated
emulators instead of software emulated ARM emulators.

In order to enable KVM module for your `container`s, simply add `kvm: true` to your `container` declaration. Here is an
example of how to configure a task capable of running hardware accelerated Android emulators:

```yaml
task:
  name: Integration Tests (x86)
  container:
    image: cirrusci/android-sdk:29
    kvm: true
  accel_check_script: emulator -accel-check
```

!!! warning "Scheduling Times of KVM-enabled Containers"
    Because of the additional virtualization layer, it takes about a minute extra to acquire necessary resources to start a task.

### Working with Private Registries

It is possible to use private Docker registries with Cirrus CI to pull containers. To provide an access to a private registry 
of your choice you'll need to obtain a JSON Docker config file for your registry and create an [encrypted variable](writing-tasks.md#encrypted-variables)
for Cirrus CI to use.

Let's check an example of setting up Oracle Container Registry in order to use Oracle Database in tests.

First, you'll need to login with the registry by running the following command:

```bash
docker login container-registry.oracle.com
```

After a successful login, Docker config file located in `~/.docker/config.json` will look something like this:

```json
{
  "auths": {
    "container-registry.oracle.com": {
      "auth": "...."
    }
  }
}
```

If you don't see `auth` for your registry it means your Docker installation is using a credentials store. In this case
you can manually auth, it's simply Base64 encoded string of your username and your PAT ([Personal Access Token](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token)):

```bash
echo $USERNAME:$PATH | base64
```

Create an [encrypted variable](writing-tasks.md#encrypted-variables) from the Docker config and put in `.cirrus.yml`:

```yaml
registry_config: ENCRYPTED[...]
```

Now Cirrus CI will be able to pull images from Oracle Container Registry:

```yaml
registry_config: ENCRYPTED[...]

test_task:
  container:
    image: bigtruedata/sbt:latest
    additional_containers:
      - name: oracle
        image: container-registry.oracle.com/database/standard:latest
        port: 1521
        cpu: 1
        memory: 8G
   build_script: ./build/build.sh
```
