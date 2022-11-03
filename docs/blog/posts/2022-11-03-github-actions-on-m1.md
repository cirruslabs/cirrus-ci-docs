---
draft: false
date: 2022-11-03
links:
  - blog/posts/2021-01-26-new-macos-task-execution-architecture.md
  - blog/posts/2022-07-07-isolating-network-between-tarts-macos-virtual-machines.md
authors:
  - fkorotkov
categories:
  - announcement
  - macos
---

# GitHub Actions on M1 via Cirrus Runners

Apple Silicon is the inevitable future. Apple has no plans to release any x86 hardware anymore. In addition, many people reported huge performance improvements after switching their builds to Apple Silicon.
There are no excuses not to switch to Apple Silicon except if your CI is not supporting it yet.

In this case, we are happy to announce *Cirrus Runners* -- managed Apple Silicon infrastructure for your existing CI.
Cirrus Runners are powered by the same infrastructure we've built other the years running macOS tasks as part of Cirrus CI.
We believe we have the most advanced and scalable tech out there for running macOS CI. We even created and [open-sourced](https://github.com/cirruslabs/tart) our own virtualization technology for Apple Silicon!

<!-- more -->

# Configuration

We are starting with GitHub Actions support first. Just install [Cirrus Runners App](https://github.com/apps/cirrus-runners)
and configure your subscription for as many runners as your organization needs. Then change `runs-on` of your workflow to use any of the [supported and managed by us images](https://github.com/orgs/cirruslabs/packages?tab=packages&q=macos-ventura):

```yaml
name: Test Suite
jobs:
  test:
    runs-on: ghcr.io/cirruslabs/macos-ventura-xcode:latest
```

Each GitHub Action job will be executed in a one-time use virtual machine to ensure reproducibility and security of your workflows.
When workflows are executing you'll see Cirrus on-demand runners on your organization's settings page at `https://github.com/organizations/<ORGANIZATION>/settings/actions/runners`.

![](/blog/images/github-actions-dashboard.png)

# Performance and Pricing

Each Cirrus Runner has 4 M1 cores comparing to GitHub's own macOS Intel runners with just 3 cores.
On average you should expect double the performance of your actions after the switch.

There is **no limit on the amount of minutes for your workflows**. Each Cirrus Runner costs $150 a month and you can utilize them `24x7`.
For comparison, fully utilizing a slower Intel runner provided by GitHub will cost you roughly `$3456` a month which is 20 times more expensive.

We recommend to purchase several Cirrus Runners depending on your team size so you can run actions in parallel. 
Note that you can change your subscription at any time via [this page](https://billing.stripe.com/p/login/3cs7vNbzo92p7fy3cc). 

# Conclusion

Mobile CI and particularly managing Apple hardware is very difficult. We've spent years trying different approaches and polishing our setup
and now we are happy to share it beyond Cirrus CI.

Have you already switched to Apple Silicon and how do you like it? Don’t hesitate to send us your feedback either [on Twitter](https://twitter.com/cirrus_labs) or via [email](mailto:hello@cirruslabs.org)!
