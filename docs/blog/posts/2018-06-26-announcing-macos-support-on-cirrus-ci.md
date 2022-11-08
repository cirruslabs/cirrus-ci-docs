---
draft: false
date: 2018-06-26
authors:
  - fkorotkov
categories:
  - announcement
  - macos
---

# Announcing macOS support on Cirrus CI

Cirrus CI already had great Linux and Windows support. The only missing platform was macOS and there was a good reason for that.

**TLDR:** Please check [documentation](https://cirrus-ci.org/guide/macOS/) for just instructions on how to configure macOS builds on Cirrus CI. The is a little bit of history and motivation below.

<!-- more -->

![](/blog/images/cirrus-clouds.jpeg)

Traditionally Linux has the best tooling. There are cloud providers that can give you a Linux VM almost instantly via an API request. Containers were pioneered on Linux. Nowadays Windows tools are catching up. The same cloud providers now have Windows VMs. Windows containers are rapidly evolving and already heavily used in production.

macOS world is not that bright. Apple is not investing into making macOS something more than a desktop OS. Only thanks to independent companies engineers can improve their lives.

![](/blog/images/anka.png)

For example, Veertu brings a container-like feel to managing macOS VMs with their [Anka Virtualization technology](https://veertu.com/anka-technology/). **Anka VMs are fast!** Their Instant Start technology allows to start VMs in less than a second for on-demand workloads ideal for CI. Anka Controller and Anka Registry brings a Docker-like feel to managing and orchestrating macOS VMs.

![](/blog/images/macstadium.png)

MacStadium is the best provider of Apple Mac infrastructure. They have reliable and fast network and hardware in their data centers. Recently they partnered up with Veertu to offer hosted Anka on a MacStadium private cloud. Finally a solution that provides a **modern orchestration for macOS VMs**.

Today we are happy to announce support for Anka Build Cloud on Cirrus CI. Open Source Projects can try [**macOS builds free of charge](https://cirrus-ci.org/guide/macOS/)**. To try the power on Anka Virtualization on your OSS projects simply add following to your `.cirrus.yml` configuration file:

```yaml
task:
  osx_instance:
    image: high-sierra-xcode-9.4
  script: ...
```

For a real-life example please check how [Chrome’s Puppeteer team tests headless Chrome on macOS](https://github.com/GoogleChrome/puppeteer/blob/master/.cirrus.yml#L24-L34).

Private organizations with more serious workloads can use a separate Anka Build Cloud. Simply sign up for an Anka cloud with MacStadium and configure it as described in [documentation](https://cirrus-ci.org/guide/supported-computing-services/#anka). Having a dedicated Anka Build Cloud for your organization has many benefits:

* **Security**. The infrastructure is not shared. No need to think about bugs in macOS kernel or virtualization that can potentially give escalated access to VMs running on the same host with your CI builds.

* **Flexibility**. By creating custom Anka VMs with all tools pre-installed you can drastically improve CI build times.

* **Scalability**. The folks at MacStadium specialize in helping you figure out your initial setup. Start small and grow your cloud as needed.

Follow us on [Twitter](https://twitter.com/cirrus_labs) and if you have any questions don’t hesitate to [ask](http://cirrus-ci.org/#/support).
