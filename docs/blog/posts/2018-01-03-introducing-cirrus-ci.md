---
draft: false
date: 2018-01-03
authors:
  - fkorotkov
categories:
  - announcement
---

# Introducing Cirrus CI

“Wait what!? Yet another CI? Gosh…” one can say after seeing the title. Honestly, at Cirrus Labs we had the same thoughts and we tried to talk ourselves out of building yet another CI. But let us explain why we think there is a need for a better CI and how Cirrus CI is better.

![Cirrus CI UI](/blog/images/cirrus-ci-ui.png)

<!-- more -->

## Why?

There are continuous integration systems that have been in development for 10+ years. They are super flexible and can be configured for almost any workflow. But this flexibility and long history bring some fundamental problems:

* It’s so easy to mess up because they are complicated.

* Which plugins to install and which to uninstall?

* How to configure builds?

* How to configure auto-scalable agent pools(machines that executes builds)?

* How to update agent pools so as to not affect builds in flight? And make sure old release branches can still be executed.

Basically there should be someone in your organization very knowledgeable to properly configure and **maintain** CI.

There are also some modern CI-as-a-service systems created in the last 6 years which are not so flexible, but they are doing great job of making continuous integration as simple as possible. Those also have some common
inconveniences like:

* **Not pay-as-you-go approach for pricing**. Usually users pay for how many jobs one can execute in parallel. Which means the users need to plan and pay for the maximum load they’ll ever have, or face queuing issues otherwise. This is not a suitable pricing model for the era of cloud computing.

* Focused mostly on containers which many businesses have not yet migrated their legacy projects to.

* **Poor environment flexibility**. Usually it’s not possible to specify precisely which VM image or Docker container to run and how much resources it can have. This means that **code is most likely tested in the environment very different from the production environment**.

Because of all the problems and inconveniences described above, we decided to build Cirrus CI with three simple principles in mind:

### Simple in details

Every architecture decision, every building block should be self-contained, well abstracted, intuitive and easily replaceable in the future. Think about it as Lego bricks: every single piece is simple but together they can form more complex element which will form the final object.

### Efficient everywhere

Since every building block is simple, self-contained and replaceable, they can also be very efficient. Optimizing small parts of the system independently is much easier than optimizing the whole system at once.

### Transparent and honest with users

Users shouldn’t guess what is happening. What you write and configure is what you get. Things can seem to be magical but there should be no magic and guessing for a user.

## How?

Cirrus CI has all features a modern CI system should have and we won’t focus on them right now. Please check [documentation](http://cirrus-ci.org/#/) for more details.

**The interesting part is how builds are executed.** Usual CI system has agents that wait for builds and execute them. Cirrus CI, on the other hand, delegates execution to [a computing service of your choice](https://cirrus-ci.org/guide/supported-computing-services/). For example, Cirrus CI can connect to a Kubernetes Cluster and schedule a task there or use Google Compute Engine APIs to schedule a task on a newly created virtual machine. **No need to configure and maintain agents.** Cirrus CI manages and orchestrates everything. A customer **pays the cloud provider directly and only for the resources used** to run CI builds and store build artifacts.

Please check a separate [blog post with all juicy technical details](https://medium.com/p/8a38aa4576d6) about what powers Cirrus CI. Or check a [high-level overview of how a single build is executed](https://cirrus-ci.org/guide/build-life/).

Follow us on [Twitter](https://twitter.com/cirrus_labs) and if you have any questions don’t hesitate to [ask us](https://cirrus-ci.org/support/).
