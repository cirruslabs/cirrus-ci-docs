# Supported Computing Services

For every [task](docs/writing-tasks.md) Cirrus CI start a new Virtual Machine or a new Docker Container on a given compute service.
Using a new VM or a new Docker Container each time for running tasks has many benefits:
* *Atomic changes to an environment where tasks are executed.* Everything about a task is configured in `.cirrus.yml` file including
VM image version and Docker Container image version. After commiting changes to `.cirrus.yml` not only new tasks will use the new environment
but also outdated branches will continue using the old configuration.
* *Reproducibility.* Fresh environment guarantees no corrupted artifacts or caches are presented from the previous tasks.
* *Cost efficiency.* Most compute services are offering per-second pricing which makes them ideal for using with Cirrus CI. 
Also each task for repository can define ideal amount of CPUs and Memory specific for a nature of the task. No need to manage
pools of similar VMs or try to fit workloads within limits of a given Continuous Integration systems.

To be fair there are of course some disadvantages of starting a new VM or a container for every task:
* *Virtual Machine Startup Speed.* Starting a VM can take from a few dozen seconds to a minute or two depending on a cloud provider and
a particular VM image. Starting a container on the other hand just takes a few hundred milliseconds! But even a minute
on average for starting up VMs is not a big inconvenience in favor of more stable, reliable and more reproducible CI.
* *Cold local caches for every task execution.* Many tools tend to store some caches like downloaded dependencies locally
to avoid downloading them again in future. Since Cirrus CI always uses fresh VMs and containers such local caches will always
be empty. Performance implication of empty local caches can be avoided by using Cirrus CI features like 
[built-in caching mechanism](docs/writing-tasks.md#cache-instruction). Some tools like [Gradle](https://gradle.org/) can 
even take advantages of [built-in HTTP cache](docs/writing-tasks.md#http-cache)!

Please check the list of currently supported cloud compute services below and please see what's [coming next](#coming-soon).

## Community Cluster

Community Cluster is simply a [Kubernetes](https://kubernetes.io/) cluster running on [Google Kubernetes Engine](#google-kubernetes-engine)
that is available free of change for Open Source community. Paying customers can also use Community Cluster for personal private repositories.

## Google Compute Engine

## Google Kubernetes Engine

## Coming Soon

We are actively working on supporting AWS and Azure and planning to release support for them in the end of Q1 2018.
