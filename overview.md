# Overview

Cirrus CI is a modern continuous integration as a service solution that takes advantages of cloud computing services. 
Cirrus CI allows customers to schedule CI builds on [variety of cloud services](docs/supported-computing-services.md) and 
pay directly to a cloud provider only for resources that were used to run CI builds and store build artifacts. 

For private repositories Cirrus CI takes a [small per user fee](pricing.md) for scheduling and orchestrating builds. 
Cirrus CI is free for Open Source projects.

?> [Community Cluster](docs/supported-computing-services.md#community-cluster) is available free of charge 
to Open Source community and for private personal repositories.

# Why Cirrus CI

* "Why yet another CI? There are gazillion of them already!"
* "We have X already configured. It's working for us. Why should we switch?"

These are all valid concerns. And at [Cirrus Labs](http://cirruslabs.org/) we had them all before we decided to build a new CI. 
We wouldn't built it if we didn't think it's necessary and there is no need for a better CI.

There are continuous integration systems that has been in development for 10+ years. They are super flexible and 
can be configured for almost any workflow. But this flexibly and long history brings some fundamental problems:

* It's so easy to mess up.
* Which plugins to install and which to uninstall?
* How to configure builds?
* How to configure auto-scalable agent pools? 
* How to update agent pools so it doesn't affect builds in flight. Or old release branches can still be executed.

Basically there should be someone very knowledgeable to properly configure and **maintain** CI.

There are also some modern CI as a service systems founded in the last 6 years which are not so flexible 
but they are doing great job of making continuous integration as simple as possible. Those also have some common
inconveniences like:

* Not pay-as-you-go approach for pricing. Usually users pay for how many containers at a time one can execute. 
Which means if users don't want to face queuing issues they need to plan and pay for the maximum load they'll have. 
It's not pricing model for the era of cloud computing.
* Focused mostly on containers where many businesses have not yet migrated legacy projects to.
* Poor environment flexibility. It's not possible to precisely specify which VM image or Docker container to run and
how much resources it can have.

Because of all the problems and inconveniences described above we decided to built Cirrus CI with three simple principles in mind:

1. Simple in details.
2. Efficient everywhere.
3. Transparent and Honest with users. 

# Key Highlights

1. Delegates execution directly to [variety of computing services](docs/supported-computing-services.md).
2. Flexible execution environment: any Unix or Windows VM, any Docker container, any amount of CPUs, optional SSDs and GPUs.
3. Most cloud compute services have per-second billing.
4. Simple but very powerful configuration format. Learn more about how to configure tasks [here](docs/writing-tasks.md).
