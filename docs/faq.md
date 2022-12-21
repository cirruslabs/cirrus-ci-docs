# Frequently Asked Questions

## Is Cirrus CI a delivery platform?

Cirrus CI is not positioned as a delivery platform but can be used as one for many general use cases by having 
[Dependencies](guide/writing-tasks.md#dependencies) between tasks and using [Conditional Task Execution](guide/writing-tasks.md#conditional-task-execution)
or [Manual Tasks](guide/writing-tasks.md#manual-tasks):

```yaml
lint_task:
  script: yarn run lint

test_task:
  script: yarn run test

publish_task:
  only_if: $BRANCH == 'master'
  trigger_type: manual
  depends_on: 
    - test
    - lint
  script: yarn run publish
```

## Are there any limits?

Cirrus CI has the following limitations on how many CPUs for different platforms a single user can run on Cirrus Cloud Clusters
for public repositories for free:

* 16.0 CPUs for Linux platform (Containers or VMs).
* 16.0 CPUs for Arm Linux platform (Containers).
* 8.0 CPUs for Windows platform (Containers or VMs)
* 8.0 CPUs for FreeBSD VMs.
* 12.0 CPUs macOS VM (1 VM).

Note that a single task can't request more than 8 CPUs (except macOS VMs which are not configurable).

!!! note "No Monthly Minute Limit"
    There are no limits on how many minutes a month you can use! Please keep in mind that mining cryptocurrency is against our Terms of Service, and will most likely be blocked by firewall rules and other anti-fraud mechanisms. Be a good citizen in the OSS community!

If you are using Cirrus CI with your private personal repositories under the [$10/month plan](https://github.com/marketplace/cirrus-ci/plan/MDIyOk1hcmtldHBsYWNlTGlzdGluZ1BsYW45OTI=#pricing-and-setup)
**you'll have twice the limits**:

* 32.0 CPUs for Linux platform (Containers or VMs).
* 16.0 CPUs for Windows platform (Containers or VMs)
* 16.0 CPUs for FreeBSD VMs.
* 24.0 CPUs macOS VM (2 VMs).

There are no limits on how many VMs or Containers you can run in parallel if you bring [your own infrastructure](guide/supported-computing-services.md)
or use [Compute Credits](pricing.md#compute-credits) for either private or public repositories.

!!! note "No per repository limits"
    Cirrus CI doesn't enforce any limits on repository or organization levels. All the limits are on a per-user basis.
    
!!! note "Cache and Logs Redundancy"
    By default Cirrus CI persists caches and logs for 90 days. If you bring your own [compute services](guide/supported-computing-services.md)
    this period can be configured directly in your cloud provider's console.

## Repository is blocked

Free tier of Cirrus CI is intended for public OSS projects to run tests and other validations continuously.
If your repository is configured to use Cirrus CI in a questionable way to just exploit Cirrus CI infrastructure,
your repository might be blocked.

Here are a few examples of such questionable activities we've seen so far:

* Use Cirrus CI as a powerhouse for arbitrary CPU-intensive calculations (including crypto mining).
* Use Cirrus CI to download a pirated movie, re-encode it, upload as a Cirrus artifact and distribute it.
* Use Cirrus CI distributed infrastructure to emulate user activity on a variety of websites to trick advertisers.

## IP Addresses of Cirrus Cloud Clusters

Instances running on Cirrus Cloud Clusters are using dynamic IPs by default. It's possible to request
a static `35.222.255.190` IP for all the "managed-by-us" instance types except macOS VMs via `use_static_ip` field.
Here is an example of a Linux Docker container with a static IP:

```yaml
task:
  name: Test IP
  container:
    image: cirrusci/wget:latest
    use_static_ip: true
  script: wget -qO- ifconfig.co
```

## CI agent stopped responding!

It means that Cirrus CI haven't heard from the agent for quite some time. In 99.999% of the cases 
it happens because of two reasons:

1. Your task was executing on a [Cirrus Cloud Cluster](guide/supported-computing-services.md#cirrus-cloud-clusters). Cirrus Cloud Cluster 
   is backed by Google Cloud's [Preemptible VMs](https://cloud.google.com/preemptible-vms/) for cost efficiency reasons and
   Google Cloud preempted back a VM your task was executing on. Cirrus CI is trying to minimize possibility of such cases 
   by constantly rotating VMs before Google Cloud preempts them, but there is still chance of such inconvenience.

2. Your CI task used too much memory which led to a crash of a VM or a container.

## Agent process on a persistent worker exited unexpectedly!

This means that either an agent process or a VM with an agent process exited before reporting the last instruction of a task.

If it's happening for a [`macos_instance`](guide/macOS.md) then please contact [support](support.md).

## Instance failed to start!

It means that Cirrus CI has made a successful API call to a [computing service](guide/supported-computing-services.md) 
to allocate resources. But a requested resource wasn't created. 

If it happened for an OSS project, please contact [support](support.md) immediately. Otherwise check your cloud console first 
and then contact [support](support.md) if it's still not clear what happened. 

## Instance got rescheduled!

Cirrus CI is trying to be as efficient as possible and heavily uses [preemptible VMs](https://cloud.google.com/preemptible-vms/) to run majority
of workloads. It allows to drastically lower Cirrus CI's infrastructure bill and allows to provide [the best pricing model with per-second billing](pricing.md)
and [very generous limits for OSS projects](#are-there-any-limits), but it comes with a rare edge case... 

Preemptible VMs can be preempted which will require rescheduling and automatically restart tasks that were executing on these VMs. 
This is a rare event since autoscaler is constantly rotating instances but preemption still happens occasionally. 
All automatic re-runs and [stateful](guide/writing-tasks.md#stateful-tasks) tasks using [compute credits](pricing.md#compute-credits)
are always executed on regular VMs.

## Instance timed out!

By default, Cirrus CI has an execution limit of 60 minutes for each task. However, this default timeout duration can be changed
by using `timeout_in` field in `.cirrus.yml` configuration file:

```yaml
task: 
  timeout_in: 90m
  ...
```

!!! note "Maximum timeout"
    There is a hard limit of 2 hours for free tasks. Use [compute credits](pricing.md#compute-credits) or
    [compute service integration](guide/supported-computing-services.md) to avoid the limit.

## Container errored

It means that Cirrus CI has made a successful API call to a [computing service](guide/supported-computing-services.md)
to start a container but unfortunately container runtime or the corresponding computing service had an internal error.

## Only GitHub Support?

At the moment Cirrus CI only supports GitHub via a [GitHub Application](https://github.com/apps/cirrus-ci). We are planning
to [support BitBucket](https://github.com/cirruslabs/cirrus-ci-docs/issues/9) next. 

## Any discounts?

Cirrus CI itself doesn't provide any discounts except [Cirrus Cloud Cluster](guide/supported-computing-services.md#cirrus-cloud-clusters) 
which is free for open source projects. But since Cirrus CI delegates execution of builds to different computing services,
it means that discounts from your cloud provider will be applied to Cirrus CI builds.
