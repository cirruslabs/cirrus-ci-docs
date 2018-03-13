# Cirrus CI

Cirrus CI is a modern continuous-integration-as-a-service solution that takes advantage of cloud computing services. 
Cirrus CI allows customers to schedule CI builds on [variety of cloud services](guide/supported-computing-services.md) and 
pay the cloud provider directly and only for the resources used to run CI builds and store build artifacts. 

At the moment Cirrus CI [supports only GitHub](faq.md#only-github-support). For private repositories Cirrus CI takes a [small per-user fee](pricing.md) for scheduling and orchestrating builds. 
Cirrus CI is free for Open Source projects.

!!! info
    [Community Cluster](guide/supported-computing-services.md#community-cluster) is available free of charge 
    to Open Source community and with no extra fee for private personal repositories.

## Key Highlights

* [Free for Open Source](guide/supported-computing-services.md#community-cluster) or per-second billing otherwise.
* Can delegate execution directly to [variety of computing services](guide/supported-computing-services.md).
* Flexible execution environment: any Unix or Windows VM, any Docker container, any amount of CPUs, optional SSDs and GPUs.
* Simple but very powerful configuration format. Learn more about how to configure tasks [here](guide/writing-tasks.md). Configure things like:
    - [Matrix Builds](guide/writing-tasks.md#matrix-modification)
    - [Dependencies between tasks](guide/writing-tasks.md#dependencies)
    - [Conditional Task Execution](guide/writing-tasks.md#conditional-task-execution)
    - [Local HTTP Cache](guide/writing-tasks.md#http-cache)

Try Cirrus CI with a [Quick Start](guide/quick-start.md) guide.

## Why Cirrus CI

* "Why yet another CI? There are gazillions of them already!"
* "We have X already configured. It's working for us. Why should we switch?"

These are all valid concerns. And at [Cirrus Labs](http://cirruslabs.org/) we had them all before we decided to build a new CI. 
We wouldn't have built it if we didn't think it's necessary and there is no need for a better CI.

There are continuous integration systems that have been in development for 10+ years. They are super flexible and 
can be configured for almost any workflow. But this flexibility and long history bring some fundamental problems:

* It's so easy to mess up.
* Which plugins to install and which to uninstall?
* How to configure builds?
* How to configure auto-scalable agent pools? 
* How to update agent pools so as to not affect builds in flight. Or old release branches can still be executed.

Basically there should be someone very knowledgeable to properly configure and **maintain** CI.

There are also some modern CI-as-a-service systems founded in the last 6 years which are not so flexible, 
but they are doing great job of making continuous integration as simple as possible. Those also have some common
inconveniences like:

* Not pay-as-you-go approach for pricing. Usually users pay for how many containers at a time one can execute. 
Which means if users don't want to face queuing issues they need to plan and pay for the maximum load they'll have. 
This is not a suitable pricing model for the era of cloud computing.
* Focused mostly on containers which many businesses have not yet migrated their legacy projects to.
* Poor environment flexibility. It's not possible to specify precisely which VM image or Docker container to run and
how much resources it can have.

Because of all the problems and inconveniences described above, we decided to build Cirrus CI with three simple principles in mind:

1. Simple in details.
2. Efficient everywhere.
3. Transparent and honest with users. 

## Comparison with popular CIaaS

Here is a high level comparison with popular continuous-integration-as-a-service solutions:

Name      | Linux Support      | Windows Support    | MacOS Support       | Customizable CPU/Memory | Pricing
----------| -----------------  | ------------------ | ------------------- | ----------------------- | -----------------------
Cirrus CI | :white_check_mark: | :white_check_mark: | [In development][1] | :white_check_mark:      | Only for used resources + [discounts][2]
Travis CI | :white_check_mark: | :x:                | :white_check_mark:  | :x:                     | Max parallel builds
Circle CI | :white_check_mark: | :x:                | :white_check_mark:  | :white_check_mark:      | Max parallel builds
AppVeyor  | :x:                | :white_check_mark: | :x:                 | :x:                     | Max parallel builds

[1]: https://github.com/cirruslabs/cirrus-ci-docs/issues/4
[2]: /faq.md#any-discounts

Feel free to [contact support](mailto:support@cirruslabs.org) if you have questions for your particular case.
