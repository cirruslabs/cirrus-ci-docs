---
draft: false
date: 2023-07-17
search:
  exclude: true
authors:
  - fkorotkov
categories:
  - announcement
---

# Limiting free usage of Cirrus CI

Unfortunately the day has come. As a self-bootstrapped company Cirrus Labs can no longer provide unlimited usage of Cirrus CI
for public repositories for free. We have to put a limit on the amount of compute resources that can be consumed for free each month
by organizations and users. Starting September 1st 2023, there will be an upper monthly limit on free usage equal to 50 compute credits
(which is equal to a little over 16,000 CPU-minutes for Linux tasks).

The reason for the change is that we want to continue being a profitable business and keep Cirrus CI running,
but unfortunately we haven’t found a better solution for a couple of ongoing issues described below.

<!-- more -->

**Crypto miners are still active.** Methodically, a lot of CI vendors one after another were restricting free usage because of this [single reason](https://webapp.io/blog/crypto-miners-are-killing-free-ci/).
Only Cirrus CI and GitHub Actions have been allowing unlimited usage as of lately and we are very proud of the effort that we have put into battling with the abuse.
We tried everything from clever firewall and traffic analysis to some basic machine learning on factors like similarity of config files and CPU usage patterns.
This effort got us a silver medal in the race of providing unlimited free usage for as long as we could. Congrats GitHub Actions on getting the gold
and remaining the only CI with free unlimited usage for public repositories.

**Cirrus CI usage pattern in many cases is not optimal.** This is just an observation we made during the decision-making process.
It appears that free Cirrus CI tasks **have only 30-40% CPU utilization on average**. On the other hand,
paid **tasks that use compute credits have an average CPU utilization of 80%**. We randomly picked a handful of tasks with low CPU utilization
and discovered that many people just used the maximum possible resources that Cirrus CI allows “just because they could”.
Frequently we saw tasks requesting 8 CPUs and 24GB of memory, but in reality they used only a single CPU core.

# Silver lining

In addition to introducing the limits we will also lower the prices for the existing compute resources. Starting August 1st,
we are lowering [the existing pricing](https://cirrus-ci.org/pricing/#compute-credits) for macOS and Windows instances by 60% and
by 40% for Linux and FreeBSD instances respectively.

# How does this change affect me?

First of all, this change is not affecting the majority of users. You can check your current monthly usage on [your settings page](https://cirrus-ci.com/settings/profile/).
Starting from August, once an account reaches the expected limit there will be a warning message displayed on all tasks.

# What to do to avoid reaching the limit?

There are couple of option to avoid reaching the compute limit:

1. Improve CPU utilization of CI tasks. Cirrus CI collects CPU charts that can indicate if a particular task is not fully utilizing resources.
2. [Bring your own compute](https://cirrus-ci.org/guide/supported-computing-services/). We recommend GKE Autopilot for Container-based tasks and Google Cloud’s compute engine overall for the best stability, performance and cost-efficiency.
3. [Use compute credits](https://cirrus-ci.org/pricing/#configuring-compute-credits). Cirrus CI does per-second billing for compute resources only and doesn’t have any hidden fees like ingress/egress traffic.
4. Migrate part of the workloads to GitHub Actions or other CI provider to balance the load. For example, keep Arm workloads on Cirrus CI and move the rest elsewhere. [Cirrus CLI](https://github.com/cirruslabs/cirrus-cli) conveniently allows to run tasks defined in Cirrus Configuration format on any other CI.

# Postscript

We are committed to continue providing the best CI possible for our customers and OSS community as well. We anticipate that this change will positively impact the experience of Cirrus CI overall.
This will allow us to remove a few existing abuse detection mechanisms that ultimately are slowing down task scheduling and execution at the moment. But of course such changes will be upsetting for a few,
and we hope for understanding. If you have any questions or concerns please feel free to email us at [support@cirruslabs.org](mailto:support@cirruslabs.org).

# Can I help somehow?

Help us spread the word about Cirrus CI! As a non-tradition startup with no VC money to spare we are always optimizing costs of operating Cirrus CI for us and our users.
The innovative idea of bringing your own compute via direct integration with APIs of cloud providers allows Cirrus CI users to have the most cost-efficient and scalable CI by design.
Compute resources are created and used on demand and there is no such thing as an “idle worker”. Cirrus CI scales to 0 when there are no tasks to execute and can instantly scale to hundreds
and thousands of tasks executing in a matter of minutes.
