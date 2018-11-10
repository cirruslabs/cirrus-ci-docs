# Pricing

Cirrus CI is free for Open Source projects. For private projects Cirrus CI has couple of options depending on your needs:

1. For private personal repositories these is a [very affordable $10 a month plan](https://github.com/marketplace/cirrus-ci/plan/MDIyOk1hcmtldHBsYWNlTGlzdGluZ1BsYW45OTI=#pricing-and-setup) with 
ultimate access to community clusters for [Linux](/guide/linux.md), [Windows](/guide/windows.md) and [macOS](/guide/macOS.md) workloads.
2. Configure access to your own [compute services](#compute-services) and [pay $10/seat/month](https://github.com/marketplace/cirrus-ci/plan/MDIyOk1hcmtldHBsYWNlTGlzdGluZ1BsYW45OTM=#pricing-and-setup)
   fee for orchestrating your CI workloads on these compute services.
3. Buy [compute credits](#compute-credits) to access managed and pre-configured community clusters for [Linux](/guide/linux.md), [Windows](/guide/windows.md) and [macOS](/guide/macOS.md) workloads.

Here is a pricing model of Cirrus CI:

User | Public Repository | Private Repository
--- | --- | ---
Person | Free + Access to community cluster | [$10/month](https://github.com/marketplace/cirrus-ci/plan/MDIyOk1hcmtldHBsYWNlTGlzdGluZ1BsYW45OTI=#pricing-and-setup) + Access to community cluster
Organization | Free + Access to community cluster | <ul><li>[$10/seat/month](#compute-services) for managing CI workloads on your [compute services](#compute-services)</li><li>Buy [compute credits](#compute-credits) to access community clusters</li></ul> 

### Compute Services

Configure and connect one or several [compute services](/guide/supported-computing-services.md) to Cirrus CI and [pay $10/seat/month](https://github.com/marketplace/cirrus-ci/plan/MDIyOk1hcmtldHBsYWNlTGlzdGluZ1BsYW45OTM=#pricing-and-setup) 
for orchestrating CI workloads on these compute services. 

**Pros** of this approach:

  * Full control of underlying infrastructure. Any type of VMs and containers with any amount of CPUs and memory.
  * Most secure. Setup any firewall and access rules.
  * Pay for CI within your existing cloud and GitHub bills. 
  
**Cons** of this approach:

  * Need to configure and connect one or several [compute services](/guide/supported-computing-services.md). Might be
    nonintuitive for cases like Anka Build Cloud for macOS.
  * Might not worth the effort for a small team.

!!! info "What is a seat?"

    Seat is simply a GitHub user that initiates CI builds by pushing commints and/or creating pull requests in a **private** repository. 
    It can be a real person or a bot.
    
    For example, there are 10 people in your GitHub Organization and only 5 of them are working on several private repositories 
    where Cirrus CI is configured. The remaining 5 people are working on public repositories or not pushing changes at all. Let's say [dependabot](https://dependabot.com/) 
    is also configured for these private repositories. 
    
    In that case there are `5 + 1 = 6` seats you need to purchase Cirrus CI plan for.
    
### Compute Credits

Sometimes configuring your own [compute services](#compute-services) isn't worth it. It takes time and effort to configure
and maintain them. For such cases there is a way to use the same community clusters that the Open Source community is enjoying.
Use compute credits with your private or public repositories of any scale.

1 compute credit can be bought for 1 US dollar. Here is how much 1000 minutes of CPU time will cost for different platforms:

  * 1000 minutes of 1 virtual CPU for Linux for 5 compute credits
  * 1000 minutes of 1 virtual CPU for Windows for 10 compute credits
  * 1000 minutes of 1 CPU with hyper-threading enabled (comparable to 2 vCPUs) for macOS for 30 compute credits

All tasks using compute credits are charged on per-second basis. 2 CPU Linux task takes 2 minutes? Pay **2 cents**.

!!! info "Priority Scheduling"
    Tasks that are using compute credits will be prioritized and will be scheduled as fast as possible.

**Pros** of this approach:
  
  * Use the same pre-configured infrastructure as the Open Source community is enjoying.
  * No need to configure anything. Let Cirrus CI team manage and upgrade infrastructure for you.
  * Per-second billing with no additional minimum or monthly fees.
  * Cost efficient for small teams. 
  
**Cons** of this approach:
  
  * Not cost efficient for big teams.
  * No support for exotic use cases like GPUs, SSDs and 100+ cores machines.

#### Buying Compute Credits

To see your current balance, recent transactions and to buy more compute credits go to your organization's settings page:

```bash
https://cirrus-ci.com/settings/github/MY-ORGANIZATION
```

!!! info "200 hours worth of compute credits for free!"
    Every organization on GitHub gets 60 compute credits upon Cirrus CI App installation. It has never been easier to try
    Cirrus CI on private organizational repositories.

#### Configuring Compute Credits

Compute credits can be used with any of the following instance types: `container`, `windows_container` and `osx_instance`.
No additional configuration needed.

```yaml
task:
  container:
    image: node:latest
  ...
```

!!! tip "Using compute credits for public repositories"
    If you willing to boost Cirrus CI for public repositories you need to explicitly mark a task to use compute credits
    with `use_compute_credits` field. Here is an example how to enable compute credits for internal and external collaborators:
    
    ```yaml
    task:
      use_compute_credits: $CIRRUS_USER_COLLABORATOR == 'true'
    ```
