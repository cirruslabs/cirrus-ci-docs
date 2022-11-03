---
draft: false
date: 2020-12-18
authors:
  - fkorotkov
categories:
  - announcement
  - cirrus-cli
  - workers
---

# Announcing public beta of Cirrus CI Persistent Workers

Cirrus CI pioneered an idea of directly using compute services instead of requiring users to manage their own infrastructure, configuring servers for running CI jobs, performing upgrades, etc. Instead, Cirrus CI just uses APIs of cloud providers to create virtual machines or containers on demand. This fundamental design difference has multiple benefits comparing to more traditional CIs:

<!-- more -->

1. **Ephemeral environment.** Each Cirrus CI task starts in a fresh VM or a container without any state left by previous tasks.
2. **Infrastructure as code.** All VM versions and container tags are specified in `.cirrus.yml` configuration file in your Git repository. For any revision in the past Cirrus tasks can be identically reproduced at any point in time in the future using the exact versions of VMs or container tags specified in `.cirrus.yml` at the particular revision. Just imagine how difficult it is to do a security release for a 6 months old version if your CI environment independently changes.
3. **Predictability and cost efficiency.** Cirrus CI uses elasticity of modern clouds and creates VMs and containers on demand only when they are needed for executing Cirrus tasks and deletes them right after. Immediately scale from 0 to hundreds or thousands of parallel Cirrus tasks without a need to over provision infrastructure or constantly monitor if your team has reached maximum parallelism of your current CI plan.

For some use cases the traditional CI setup is still useful. However, not everything is available in the cloud. For example, Apple releases new ARM-based products and there is simply no virtualization yet available for the new hardware. Another use case is to test the hardware itself, since not everyone is working on websites and mobile apps after all! For such use cases it makes sense to go with a traditional CI setup: install some binary on the hardware which will constantly pull for new tasks and will execute them one after another.

This is precisely what Persistent Workers for Cirrus CI are: a simple way to run Cirrus tasks beyond cloud! **Run Cirrus CI on any hardware including the new Apple Silicon, any other ARM or even things like IBM Z!**

![](/blog/images/airbnb-mobile-ci.jpeg)

Please follow documentation in order to configure your first persistent worker and please report any issues/ask question either [on Twitter](https://twitter.com/cirrus_labs) or through [GitHub issues](https://github.com/cirruslabs/cirrus-ci-docs).
