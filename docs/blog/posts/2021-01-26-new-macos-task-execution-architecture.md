---
draft: false
date: 2021-01-26
authors:
  - fkorotkov
categories:
  - announcement
  - cirrus-cli
  - workers
  - macos
---

# New macOS task execution architecture for Cirrus CI

We are happy to announce that the macOS tasks on Cirrus CI Cloud have switched to a new virtualization technology as well as overall architecture of the orchestration. This switch should be unnoticeable for the end users except that the tasks should become much faster since now each `macos_instance` of the Cirrus CI Cloud offering will utilize a full Mac Mini with 12 virtual CPUs and 24G of RAM.

<!-- more -->

The new architecture is built on top of the recently announced [Persistent Workers](https://cirrus-ci.org/guide/persistent-workers) functionality and can be easily replicated with on-premise Mac hardware by any Cirrus CI user or on any other CI by using [Cirrus CLI](https://github.com/cirruslabs/cirrus-cli).

We know from experience that continuous integration for macOS is the hardest and how little information there is about the topic on the internet! And we want to share below how the new simplified architecture looks like and how to replicate it.

Cirrus CI architecture is very simple. There is Cirrus Agent (a self contained [binary written in Go](https://github.com/cirruslabs/cirrus-ci-agent)) which job is to simply execute scripts, download/upload caches, parse test reports and stream progress via gRPC API. Both Cirrus CI Cloud and Cirrus CLI implement the same gRPC API so the agent binary doesn’t even know in which environment it’s been executed.

![](/blog/images/new-architecture-cloud-schema.png)
![](/blog/images/new-architecture-local-schema.png)

Cirrus CLI initially was intended to be a local executor of Cirrus Tasks in Docker containers only. Cirrus CLI simply parses Cirrus configuration file and then uses Docker daemon API to start/stop containers to execute parsed tasks. Note that Cirrus CLI doesn’t require to use Cirrus CI Cloud and can be used with any other CI. Once this functionality was ironed out and well tested it was easy to add an option to use Parallels virtualization instead of Docker containers to execute tasks in.

Before that Cirrus used Anka cloud which required a complex setup of Controller/Registry services that were orchestrating execution of Anka VMs on the hosts.

![](/blog/images/new-architecture-old-anka.png)

With Persistent Workers we were able not only to dogfood Cirrus CI’s own functionality but also cut the *middle man* of Anka Controller which was contributing to the “created to execution” metric of macOS tasks. Now macOS tasks will be scheduled even faster! Here is how simple the current architecture look like:

![](/blog/images/new-architecture-workers.png)

As you can see this new architecture is not rocket science and somewhat very traditional. The key here is that Cirrus CLI can isolate task execution in a Parallels VM. Under the hood the following configuration

```yaml
task:
  name: macOS tests
  macos_instance:
    image: big-sur-base
```

Will be translated to:

```yaml
task:
  name: macOS tests
  persistent_worker:
    isolation:
      parallels:
        image: big-sur-base
        user: SSH_USERNAME
        password: SSH_PASSWORD
        platform: darwin
```

This configuration can be easily executed locally or in any other CI via Cirrus CLI.

We are very excited about the new architecture and opportunity to dogfood persistent workers functionality at scale! Please let us know how new architecture works for your projects (especially since there are `3x` more CPU resources and better network performance) and send us feedback either on GitHub or on Twitter!
