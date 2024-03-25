---
hide:
  - navigation
  - toc
---
## Free for Open Source 

To support the Open Source community, Cirrus CI provides [Linux](guide/linux.md), [Windows](guide/windows.md), [macOS](guide/macOS.md) and [FreeBSD](guide/FreeBSD.md)
services free of charge up to [a cap of 50 compute credits](faq.md#are-there-any-limits) a month to OSS projects.

Here is a list of all instance types available for free for Open Source Projects:

| Instance Type             | Managed by | Description                                                         |
|---------------------------|------------|---------------------------------------------------------------------|
| `container`               | **us**     | [Linux Docker Container][container]                                 |
| `arm_container`           | **us**     | [Linux Arm Docker Container][container]                             |
| `windows_container`       | **us**     | [Windows Docker Container][windows_container]                       |
| `docker_builder`          | **us**     | [Full-fledged VM pre-configured for running Docker][docker_builder] |
| `macos_instance`          | **us**     | [macOS Virtual Machines][macos_instance]                            |
| `freebsd_instance`        | **us**     | [FreeBSD Virtual Machines][freebsd_instance]                        |
| `compute_engine_instance` | **us**     | [Full-fledged custom VM][compute_engine_instance]                   |
| `persistent_worker`       | **you**    | [Use any host on any platform and architecture][persistent_worker]  |

[container]: guide/linux.md
[windows_container]: guide/windows.md
[docker_builder]: guide/docker-builder-vm.md
[macos_instance]: guide/macOS.md
[freebsd_instance]: guide/FreeBSD.md
[compute_engine_instance]: guide/custom-vms.md
[persistent_worker]: guide/persistent-workers.md

## Per-second billing

Use [compute credits](pricing.md#compute-credits) to run as many parallel tasks as you want and pay only for CPU time
used by these tasks. Another approach is to [bring your own infrastructure](#bring-your-own-infrastructure) and pay directly to your cloud provider
within your current billing.

## No concurrency limit. No queues

Cirrus CI leverages elasticity of the modern clouds to always have available resources to process your builds.
**Engineers should never wait for builds to start**.

## Bring Your Own Infrastructure 

Cirrus CI supports [bringing your own infrastructure](guide/supported-computing-services.md) (BYO) for full control over security and for easy integration with
your current workflow.

<p align="center">
  <a href="/guide/supported-computing-services#google-cloud">
    <img style="width:128px;height:128px;" src="/assets/images/gcp/Google Cloud Platform.svg"/>
  </a>
  <a href="/guide/supported-computing-services#aws">
    <img style="width:128px;height:128px;" src="/assets/images/aws/AWS.svg"/>
  </a>
  <a href="/guide/supported-computing-services#azure">
    <img style="width:128px;height:128px;" src="/assets/images/azure/Microsoft Azure.svg"/>
  </a>
</p>

## Flexible runtime environment
 
Cirrus CI allows you to use any Unix or Windows VMs, any Docker containers, any amount of CPUs, optional SSDs and GPUs.

## Basic but very powerful configuration format 

Learn more about how to configure tasks [here](guide/writing-tasks.md).
Configure things like:

* [Matrix Builds](guide/writing-tasks.md#matrix-modification)
* [Dependencies between tasks](guide/writing-tasks.md#dependencies)
* [Conditional Task Execution](guide/writing-tasks.md#conditional-task-execution)
* [Local HTTP Cache](guide/writing-tasks.md#http-cache)
* [Dockerfile as a CI environment](guide/docker-builder-vm.md#dockerfile-as-a-ci-environment)
* [Monorepo Support](guide/writing-tasks.md#supported-functions)

Check the [Quick Start](guide/quick-start.md) guide for more features.

Feel free to [contact support](mailto:support@cirruslabs.org) if you have questions for your particular case.
