---
draft: false
date: 2022-11-08
links:
  - blog/posts/2018-06-26-announcing-macos-support-on-cirrus-ci.md
  - blog/posts/2020-12-18-persistent-workers.md
  - blog/posts/2021-01-26-new-macos-task-execution-architecture.md
  - blog/posts/2022-07-07-isolating-network-between-tarts-macos-virtual-machines.md
authors:
  - fkorotkov
categories:
  - announcement
  - macos
---

# Sunsetting Intel macOS instances

**TLDR** Intel-based Big Sur and High Sierra instances will stop working on January 1st 2023. Please migrate to [M1-based Monterey and Ventura instances](/guide/macOS.md).
Below we'll provide some history and motivation for this decision.

## Evolution of macOS infrastructure for Cirrus CI

We've been running macOS instances for almost 5 years now. We evaluated all the existing solutions and even successfully
operated two of them on Intel platform before creating our own virtualization toolset for Apple Silicon called [*Tart*](https://github.com/cirruslabs/tart).
We are switching [managed-by-us macOS instances](/guide/macOS.md) to exclusively running in Tart virtual machines **starting January 1st 2023**.

<!-- more -->

### First generation with Anka

![](/blog/images/new-architecture-old-anka.png)

We started back in 2018 by adopting pretty new at the time virtualization technology called Anka. It worked fairly well for us to some extent.
We started hitting first scaling issues pretty quickly when we reached around a dozen Mac Minis in our fleet. Anka Registry was just bounded by the I/O of a single
server that it was deployed too. **You can't distribute huge 50+ GB templates to dozens of hosts simultaneously from a single server!**

We had to implement some extra Ansible magic that distributed these templates via `scp` in `log(n)` where `n` is the number of Mac Minis in one data center.
The magic pulled a new template from Anka registry to a single host, then the next two hosts instead of pulling from the registry, used `scp` to copy
from the previous hosts, etc. That unblocked our growth and we continued using Anka.

Then in the end of 2019 - early 2020 there were a bunch of transient issues with Anka's networking layer. Sometimes some hosts were just loosing
internet connections and all consecutive Anka VMs were not able to run anything until a restart of a host. We spent countless hours with Veertu folks
trying to debug this transient but very annoying issue with no luck. In the end we had to implement some workaround and detections on our end.
At this point we started thinking of a way to replace Anka Controller, so we could potentially switch the virtualization layer as well.

With that in mind we started working on [Cirrus CLI](https://github.com/cirruslabs/cirrus-cli) -- a CI-agnostic tool that can run "tasks" locally in containers or VMs.

### Second generation with Parallels

![](/blog/images/new-architecture-workers.png)

Throughout 2020, we switched from an Anka cluster managed by MacStadium to a self-managed installation. We deployed
Anka Registry and Anka Controller on Google Cloud and got Mac Minis evenly distributed between two [`MacMiniVault`](https://www.macminivault.com/) data centers for redundancy.
We perfected our Ansible cookbooks and got very comfortable with rolling updates so we don't have downtime. We also prepared
Packer templates to automate creation of Virtual Machines.

In parallel Cirrus CLI matured, it was able to run tasks in Docker containers. It was time to find a replacement for Anka.
We had two criteria in mind: cost-efficiency and network stability. After some research we ended up with Parallels.
Network performance was better, starting time for VMs was a little slower but still very fast. And price! Anka's
license costed us more than we paid for the hardware we rented to run it! Parallels was just $10/month/host.

Long story short, we added necessary features to Cirrus CLI to run tasks in Parallels VMs, used the same Packer templates
to rebuild all the virtual machines. And in early 2021 did the switch!

### Third generation with Tart

<img src="https://github.com/cirruslabs/tart/raw/main/Resources/TartSocial.png"/>

In the meantime Apple Silicon was taking off. It was clear Apple was very serious about the transition and full switch from Intel processors.
But at the time none of the virtualization solutions supported Apple Silicon. It was a new stack with new challenges.

Thankfully in the end of 2021 with macOS Monterey release Apple themselves released `Virtualization.Framework`, so companies like
Veertu and Parallels don't need to re-invent the wheel and reverse engineer all the things about macOS.

By February 2022 we were getting more and more requests to support M1 workloads in our CI but none of the virtualization
solution adopted `Virtualization.Framework`, except for Anka 3.0. A switch back was off the table. Anka pricing was
the same even though there is now little "knowhow" because Apple liberated this knowledge with `Virtualization.Framework`.

We decided to give it a try and build our own virtualization solution. Couple months later we open-sourced Tart and
a couple other tools to help everyone with automation needs on Apple Silicon. One unique feature of Tart is integration with
OCI-compatible container registries to Push/Pull virtual machines from them. It simplifies distribution of huge virtual machines
to hundreds of Mac Minis because cloud container registries are super scalable.

We also added another fleet of M1 Mac Minis and offered M1 macOS virtual machines as part of Cirrus CI which also includes free tier for open-source projects.

## Inevitable Future

Apple no longer sells Intel-based hardware, and it's just a matter of time for a full transition. For us, continuing managing
the second generation of infrastructure is becoming a burden. We are fully committing to supporting Apple Silicon and decided
to sunset our Intel-based offering from January 1st 2023.

Please migrate your Big Sur and High Sierra `macos_instance`s to Monterey or Ventura. Refer to [documentation](/guide/macOS.md) for more details.

Have any questions? Still need to test on Intel? Don’t hesitate to send us your feedback either [on Twitter](https://twitter.com/cirrus_labs) or via [email](mailto:hello@cirruslabs.org)!
