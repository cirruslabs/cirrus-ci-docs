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
