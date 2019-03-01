## Linux Containers

Linux Community Cluster is a [Kubernetes](https://kubernetes.io/) cluster running on [Google Kubernetes Engine](supported-computing-services.md#google-kubernetes-engine)
that is available free of charge for Open Source community. Paying customers can also use Community Cluster for 
personal private repositories or buy CPU time with [compute credits](../pricing.md#compute-credits) for their private organization repositories.

Community Cluster is configured the same way as anyone can configure a personal GKE cluster as [described here](supported-computing-services.md#google-kubernetes-engine).

By default a container is given 2 CPUs and 4 Gb of memory but it can be configured in `.cirrus.yml`:

```yaml
container:
  image: openjdk:8-jdk
  cpu: 4
  memory: 12

task:
  script: ...
``` 

Containers on Community Cluster can use maximum 8.0 CPUs and up to 24 Gb of memory. 

!!! warning "Scheduling Times on Community Cluster"
    Since Community Cluster is shared, scheduling times for containers can vary from time to time. Also the smaller a container 
    require resources faster it will be scheduled.

!!! info "Privileged Access"
    If you need to run privileged docker containers, take a look at the [docker builder](docker-builder.md).

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

Create an [encrypted variable](writing-tasks.md#encrypted-variables) from the Docker config and put in in `.cirrus.yml`:

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
