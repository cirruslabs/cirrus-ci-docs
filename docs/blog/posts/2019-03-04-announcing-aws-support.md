---
draft: false
date: 2019-03-04
authors:
  - fkorotkov
categories:
  - announcement
  - aws
---

# Announcing AWS Support

Cirrus CI from the day one was build around leveraging modern cloud computing services as backends for executing CI workloads. It allows teams to own the CI infrastructure and at the same time to not have pains of configuring and managing CI agents. Anyways the idea of traditional CI agent pools is obsolete.

![](/blog/images/aws.jpg)

<!-- more -->

Cirrus CI initially launched with only Linux and Windows support through [Google Cloud integration](https://cirrus-ci.org/guide/supported-computing-services/#google-cloud), shortly Cirrus CI started [supporting Azure](https://cirrus-ci.org/guide/supported-computing-services/#azure) which enabled more sophisticated Windows Containers support, and finally, [Anka integration](https://cirrus-ci.org/guide/supported-computing-services/#anka) allowed to add very anticipated macOS support.

Today Cirrus CI starts supporting AWS services which brings even more flexibility of integrating Cirrus CI in your existing infrastructure.

Cirrus CI supports EC2 for scheduling VM-based and EKS for container-based CI tasks. Cirrus CI will store CI logs and artifacts in S3. Please check [documentation](https://cirrus-ci.org/guide/supported-computing-services/#aws) for more details.

We highly encourage you to [try out Cirrus CI](https://cirrus-ci.org/guide/quick-start/). It’s **free for Open Source projects** and very easy to setup! Also there is a 14 days free trial for private repositories.

Follow us on [Twitter](https://twitter.com/cirrus_labs) and if you have any questions don’t hesitate to [ask](https://cirrus-ci.org/support/).
