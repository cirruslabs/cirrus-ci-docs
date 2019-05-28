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

There are no limits on how many VMs or Containers you can run in parallel if you bring your own [compute services](guide/supported-computing-services.md)
or use [Compute Credits](pricing.md#compute-credits) for either private or public repositories.

Cirrus CI has following limitations on how many VMs or Containers a single user can run for free for public repositories:

* 8 Linux Containers or VMs
* 2 Windows Containers or VMs
* 2 FreeBSD VMs
* 1 macOS VM
  
Which means that a single user can run at most 13 simultaneous tasks for free.

!!! note "No per repository limits"
    Cirrus CI doesn't enforce any limits on repository or organization levels. All the limits are on per user basis.
    For example, if you have 10 active contributors to a repository then you can end up with 130 tasks running in parallel 
    for the repository.  

## IP Addresses of Community Clusters

Instances running on Community Clusters are using static IPs for outgoing traffic from the instances. Knowing these IPs
might be useful for safelisting while integrating your CI builds with external services.

Infrastructure | NAT hostname | IP
-------------- | ------------ | --
OS X | macstadium.community.nat.cirrus-ci.com | 207.254.42.60
Linux | gcp.community.nat.cirrus-ci.com | 35.222.255.190
FreeBSD | gcp.community.nat.cirrus-ci.com | 35.222.255.190
Windows 2019 | gcp.community.nat.cirrus-ci.com | 35.222.255.190
Windows 1803 | gcp.community.nat.cirrus-ci.com | 35.222.255.190
Windows 1709 | gcp.community.nat.cirrus-ci.com | 35.222.255.190
Windows 2016 (**deprecated**) | **Not Supported** | **Not Available**

## CI agent stopped responding!

It means that Cirrus CI haven't heard from the agent for quite some time. In 99.999% of the cases 
it happens because of two reasons:

1. Your task was executing on [Community Cluster](guide/supported-computing-services.md#community-cluster). Community Cluster 
   is backed by Google Cloud's [Preemptible VMs](https://cloud.google.com/preemptible-vms/) for cost efficiency reasons and
   Google Cloud preempted back a VM your task was executing on. Cirrus CI is trying to minimize possibility of such cases 
   by constantly rotating VMs before Google Cloud preempts them, but there is still chance of such inconvenience.

2. Your CI task used too much memory which led to a crash of a VM or a container.

## Instance failed to start!

It means that Cirrus CI have made a successful API call to a [computing service](guide/supported-computing-services.md) 
to allocate resources. But a requested resource wasn't created. 

If it happened for an OSS project, please contact [support](support.md) immediately. Otherwise check your cloud console first 
and then contact [support](support.md) if it's still not clear what happened. 

## Instance got rescheduled!

Cirrus CI is trying to be as efficient as possible and uses an auto-scalable cluster of [preemptible VMs](https://cloud.google.com/preemptible-vms/)
to run [Linux containers for OSS](guide/linux.md). It allows to drastically lower Cirrus CI's bill for parts of infrastructure 
that **run tasks for OSS projects free of charge** but it comes with a rare edge case... 

Preemptible VMs can be preempted which will require to reschedule and automatically restart tasks that were executing on these VMs. 
This is a rare event since autoscaler is constantly rotating instances but preemption still happens occasionally.

!!! tip "Compute Credits"
    Tasks that use [compute credits](pricing.md#compute-credits) are executed on standard VMs that don't get preempted.    

## Instance timed out!

By default Cirrus CI has an execution limit of 60 minutes for each task. However, this default timeout duration can be changed
by using `timeout_in` field in `.cirrus.yml` configuration file:

```yaml
task: 
  timeout_in: 90m
  ...
```

!!! note "Maximum timeout"
    There is a hard limit of 2 hours for community tasks. Use [compute credits](pricing.md#compute-credits) or
    [compute service integration](guide/supported-computing-services.md) to avoid the limit.

## Only GitHub Support?

At the moment Cirrus CI only supports GitHub via a [GitHub Application](https://github.com/apps/cirrus-ci). We are planning
to [support BitBucket](https://github.com/cirruslabs/cirrus-ci-docs/issues/9) next. 

## Any discounts?

Cirrus CI itself doesn't provide any discounts except [Community Cluster](guide/supported-computing-services.md#community-cluster) 
which is free for open source projects. But since Cirrus CI delegates execution of builds to different computing services,
it means that discounts from your cloud provider will be applied to Cirrus CI builds.
