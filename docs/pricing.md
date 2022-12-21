---
hide:
  - navigation
---
# Pricing

Cirrus CI is free for Open Source projects with some [limitations](faq.md#are-there-any-limits). For private projects, Cirrus CI has couple of options depending on your needs:

1. For private personal repositories there is a [very affordable $10 a month plan](https://github.com/marketplace/cirrus-ci/plan/MDIyOk1hcmtldHBsYWNlTGlzdGluZ1BsYW45OTI=#pricing-and-setup) with 
   access to Cirrus Cloud Clusters for [Linux](guide/linux.md), [Windows](guide/windows.md) and [macOS](guide/macOS.md) workloads.
2. Buy [compute credits](#compute-credits) to access managed and pre-configured Cirrus Cloud Clusters for [Linux](guide/linux.md), [FreeBSD](guide/FreeBSD.md), [Windows](guide/windows.md), and [macOS](guide/macOS.md) workloads.
3. Configure access to [your own infrastructure](#compute-services) and [pay $10/seat/month](https://github.com/marketplace/cirrus-ci/plan/MDIyOk1hcmtldHBsYWNlTGlzdGluZ1BsYW45OTM=#pricing-and-setup).

Here is a comparison table of available [Cirrus CI plans](https://github.com/marketplace/cirrus-ci):

| User         | [Free Public Repositories](https://github.com/marketplace/cirrus-ci/plan/MDIyOk1hcmtldHBsYWNlTGlzdGluZ1BsYW45OTA=#pricing-and-setup)                                                                                                                                                                                                                                                                                                                 | [Private Personal Repository](https://github.com/marketplace/cirrus-ci/plan/MDIyOk1hcmtldHBsYWNlTGlzdGluZ1BsYW45OTI=#pricing-and-setup)                                                                                                                                                               | [Private Organization Repositories](https://github.com/marketplace/cirrus-ci/plan/MDIyOk1hcmtldHBsYWNlTGlzdGluZ1BsYW45OTM=#pricing-and-setup)                                                                                                                                                                                                                                                                                                                                     |
|--------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Person       | <ul><li>Free access to Cirrus Cloud Clusters for public repositories</li><li>[Bring your own infrastructure](#compute-services) for public repositories</li><li>Configure [persistent workers](guide/persistent-workers.md) for public repositories</li></ul>                                                                                                                                                                                        | <ul><li>Access to community clusters for public and **private** repositories</li><li>[Bring your own infrastructure](#compute-services) for public and **private** repositories</li><li>Configure [persistent workers](guide/persistent-workers.md) for public and **private** repositories</li></ul> | **Not Applicable**                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| Organization | <ul><li>Free access to Cirrus Cloud Clusters for public repositories</li><li>Use [compute credits](#compute-credits) to access community clusters for private repositories and/or to avoid the [limits](faq.md#are-there-any-limits) on public repositories</li><li>[Bring your own infrastructure](#compute-services) for public repositories</li><li>Configure [persistent workers](guide/persistent-workers.md) for public repositories</li></ul> | **Not Applicable**                                                                                                                                                                                                                                                                                    | <ul><li>Free access to community clusters for public repositories</li><li>Use [compute credits](#compute-credits) to access community clusters for private repositories and/or to avoid the [limits](faq.md#are-there-any-limits) on public repositories</li><li>[Bring your own infrastructure](#compute-services) for public and **private** repositories</li><li>Configure [persistent workers](guide/persistent-workers.md) for public and **private** repositories</li></ul> |

## Compute Credits

Sometimes configuring your own [compute services](#compute-services) isn't worth it. It takes time and effort to maintain them. For such cases there is a way to use the Cirrus Cloud Clusters for your organization.

1 compute credit can be bought for 1 US dollar. Here is how much 1000 minutes of CPU time will cost for different platforms:

* 1000 minutes of 1 virtual CPU for Linux platform for 5 compute credits
* 1000 minutes of 1 virtual CPU for FreeBSD platform for 5 compute credits
* 1000 minutes of 1 virtual CPU for Windows platform for 10 compute credits
* 1000 minutes of 1 Apple Silicon CPU or 2 Intel virtual CPUs for macOS platform for 40 compute credits

All tasks using compute credits are charged on per-second basis. 2 CPU Linux task takes 2 minutes? Pay **2 cents**.

**Note:** orchestration costs are included in compute credits and there is no need to purchase additional seats on your organization's plan.

!!! info "Priority Scheduling"
    Tasks that are using compute credits will be prioritized and will be scheduled as fast as possible.

!!! tip "Works for OSS projects"
    Compute credits can be used for commercial OSS projects to avoid [concurrency limits](faq.md#are-there-any-limits).
    Note that only collaborators for the project will be able to use organization's compute credits.

**Benefits** of this approach:
  
* Use the same pre-configured infrastructure that we fine tune and constantly upgrade/improve.
* No need to configure anything. Let Cirrus CI's team manage and upgrade infrastructure for you.
* Per-second billing with no additional minimum or monthly fees.
* Cost efficient for small to medium teams. 
  
**Cons** of this approach:
  
* No support for exotic use cases like GPUs, SSDs and 100+ cores machines.
* Not that cost efficient for big teams.

### Buying Compute Credits

To see your current balance, recent transactions and to buy more compute credits, go to your organization's settings page:

```bash
https://cirrus-ci.com/settings/github/MY-ORGANIZATION
```

### Configuring Compute Credits

Compute credits can be used with any of the following instance types: `container`, `windows_container` and `macos_instance`.
No additional configuration needed.

=== "amd64"

    ```yaml
    task:
      container:
        image: node:latest
      ...
    ```

=== "arm64"

    ```yaml
    task:
      arm_container:
        image: node:latest
      ...
    ```

!!! tip "Using compute credits for public or personal private repositories"
    If you willing to boost Cirrus CI for public or your personal private repositories you need to explicitly mark a task to use compute credits
    with `use_compute_credits` field.
    
    Here is an example of how to enable compute credits for internal and external collaborators of a public repository:
    
    ```yaml
    task:
      use_compute_credits: $CIRRUS_USER_COLLABORATOR == 'true'
    ```
    
    Here is another example of how to enable compute credits for master branch of a personal private project to make sure
    all of the master builds are executed as fast as possible by skipping [free usage limits](faq.md#are-there-any-limits):
    
    ```yaml
    task:
      use_compute_credits: $CIRRUS_BRANCH == 'master'
    ```

## Compute Services

Configure and connect one or more [compute services](guide/supported-computing-services.md) and/or [persistent workers](guide/persistent-workers.md)
to Cirrus CI for orchestrating CI workloads on them. It's free for your public repositories and [costs $10/seat/month](https://github.com/marketplace/cirrus-ci/plan/MDIyOk1hcmtldHBsYWNlTGlzdGluZ1BsYW45OTM=#pricing-and-setup)
to use with private repositories unless your organization has [Priority Support Subscription](support.md#priority-support).

**Benefits** of this approach:

* Full control of underlying infrastructure. Use any type of VMs and containers with any amount of CPUs and memory.
* More secure. Setup any firewall and access rules.
* Pay for CI within your existing cloud and GitHub bills. 
  
**Cons** of this approach:

* Need to configure and connect one or several [compute services](guide/supported-computing-services.md).
* Might not be worth the effort for a small team.
* Need to pay $10/seat/month plan.

!!! info "What is a seat?"
    A seat is a user that initiates CI builds by pushing commits and/or creating pull requests in a **private** repository. 
    It can be a real person or a bot. If you are using [Cron Builds](guide/writing-tasks.md#cron-builds) or creating builds through [Cirrus's API](api.md)
    it will be counted as an additional seat (like a bot).
    
    For example, if there are 10 people in your GitHub Organization and only 5 of them are working on private repositories 
    where Cirrus CI is configured, the remaining 5 people are not counted as seats, given that they aren't pushing to the private repository. 
    Let's say [Dependabot](https://dependabot.com/) is also configured for these private repositories. 
    
    In that case there are `5 + 1 = 6` seats you need to purchase Cirrus CI plan for.
