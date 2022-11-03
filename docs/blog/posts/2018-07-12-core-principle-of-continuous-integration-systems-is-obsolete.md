---
draft: false
date: 2018-07-12
authors:
  - fkorotkov
categories:
  - announcement
---

# Core principle of Continuous Integration systems is obsolete

This blog post will briefly go through the history of CI systems and will describe how a role-model CI system works nowadays. After describing core principles of CI systems, we’ll take a look at how extremely fast evolution of cloud and virtualization technologies allowed to change these principles and especially concept of CI agents.

<!-- more -->

First time an idea of a Continuous Integration (CI) system was described in the early `90s`. But the first big win from a CI system was restraining “integration hell” for *Windows XP* release in 2001. Around that time a few CI systems were created, but only *Jenkins* lives to the current days.

These first CI systems were pretty simple. They consist of several servers AKA *agents* that are constantly pulling a single *master* server for work that they can do. Once the *master* responses with a job for a particular *agent*, the *agent* simply executes commands and streams results back to the *master*. Simple as that!

Over the years some CI best practices were established in order to achieve consistent builds on the *agents*:

* **Reproducible Environment.** Each agent should have identical environment with the same version of build tools and compilers for executing scripts. Traditionally there were pools of agents with the same environment. For example, a pool of agents with Java 8 and a pool of agents with Java 10 installed. Lately, **Docker is becoming very popular for this purpose**. There can be a single pool of agents with Docker pre-installed so an agent can execute scripts inside of a docker container instead of just shelling the command.

* **Clean Environment.** There should be no artifacts from the previous builds presented when a new build is executing on the agent. Such artifacts result in unpredictable behaviour of the agents.

![](/blog/images/schema-traditional-ci.png)

Another recent improvement to the classic CI architecture is using cloud providers to have an **auto-scalable pools of CI agents**. Modern clouds allow to spin up new VMs on demand by just calling APIs. There is no need to pre-allocate agents for the maximum load, agents can be scaled up and down pretty easily. This is a huge cost saver not only of compute resources but also of engineering time. Engineers don’t need to wait for available agents for their builds any more!

Nowadays a **role-model CI system consists of** a multi-master node and an auto-scalable pool of CI agents with Docker pre-installed somewhere in the cloud. Sounds pretty good, right?

![](/blog/images/schema-of-role-model.png)

But as you can see, the core principle of a CI system hasn’t changed in almost 20 years!

## New Idea

What if I tell you that the **idea of a CI agent pool is obsolete**? Why is there a need in CI agents in the first place? A **CI agent solves one simple problem: quickly get an environment ready to execute a CI build**.

Technological progress in the recent years redefined many expectations. For example, nowadays most of the cloud providers can **start a VM in under a minute**. There is no need to pre-allocate resources, a **modern cloud charges for seconds of compute time**. There are separate systems like Kubernetes whose purpose is quickly and efficiently allocate and manage containers. **There is no need to do the same job by maintaining CI agent pools**! One can simply **use APIs of computing services to allocate resources once they are needed** to execute new CI builds.

For example, to run a build of a web application using Node.JS, a CI system can simply use Kubernetes API to start node:latest container and use it for the CI build.

Such CI system can also leverage multiple computing services within a cloud and even use several clouds for different CI needs.

![](/blog/images/schema-new-architecture.png)

## Can it work?

**Yes, it works!** At Cirrus Labs we actually built Cirrus CI using this idea precisely. Cirrus CI leverages a [variety of modern computing services](https://cirrus-ci.org/guide/supported-computing-services/) to run CI builds. Cirrus CI simply **uses APIs of computing services to allocate resources once they are needed** to execute new CI builds, no need to maintain a CI agent pool.

Cirrus CI already supports [Google Cloud](https://cloud.google.com/), [Azure](https://azure.microsoft.com/) and [Anka Build Cloud](https://veertu.com/anka-technology/) which allows to run Linux, Windows and macOS workloads. **Cirrus CI is the only CI-as-a-service system that supports all of these platforms together**.

The idea of just using APIs of computing services not only allowed easily support a variety of platforms, but also allowed to bring a [**new pricing model](https://cirrus-ci.org/pricing/)**. Cirrus CI allows you to bring your own cloud. Simply connect part of your cloud to Cirrus CI and pay for your CI within your current cloud payment. Cirrus CI charges a [small fee](https://cirrus-ci.org/pricing/) for orchestrating CI builds of private repositories which is also billed though the already existing GitHub payment.

We highly encourage you to [try out Cirrus CI](https://cirrus-ci.org/guide/quick-start/). It’s **free for Open Source projects** and very easy to setup! Also there is a 14 days free trial for private repositories.

Follow us on [Twitter](https://twitter.com/cirrus_labs) and if you have any questions don’t hesitate to [ask](https://cirrus-ci.org/support/).
