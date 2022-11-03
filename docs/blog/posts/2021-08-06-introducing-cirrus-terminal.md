---
draft: false
date: 2021-08-06
authors:
  - edigaryev
categories:
  - announcement
  - terminal
---

# Introducing Cirrus Terminal: a simple way to get SSH-like access to your tasks

![](/blog/images/terminal.png)

Imagine dealing with a failing task that only reproduces in CI or a task with an environment that is is simply too cumbersome to bootstrap locally.

For a long time, the classic debugging approach worked just fine: do an attempt to blindly fix the issue or add debugging instructions and re-run. Got it working or found a clue? Cool. No? Do it once again!

Then [Cirrus CLI](https://github.com/cirruslabs/cirrus-cli) appeared. It allows you to replicate the CI environment locally, but complex cases like custom VMs or other architectures are not covered due to platform limitations.

Anyway, both methods require some additional tinkering to gain access to the interactive session on the host where the task runs (i.e. something similar to docker exec -it container-ID).

Luckily no more! With the recent Cirrus Terminal integration, it’s now possible to have this one click away on Cirrus Cloud!

<!-- more -->

Simply choose and click “Re-run with Terminal Access” on a task you want to gain access to:

![](/blog/images/terminal-re-run.png)

Then, shortly after the agent is started on the instance, you’ll see the console:

![](/blog/images/terminal-ui.png)

Voila! Perhaps you could get away with zero CI configuration changes this time?

## How it works

When you “Re-run with Terminal Access”, the agent running on the started instance registers itself on the Cirrus Terminal server and publishes its session credentials along with the task identification to the Cirrus Cloud.

When a task is opened in a web UI, it’ll continuously monitor the task metadata looking for the published Cirrus Terminal credentials and once found, renders a terminal and connects it to the Cirrus Terminal server.

The terminal sessions opened in the web UI are not shared, but you can open as much as you need to!

![](/blog/images/terminal-schema.png)

Talking more technical, Cirrus Terminal is implemented in Golang and [is publicly available under Apache License](https://github.com/cirruslabs/terminal). Cirrus Terminal [consists of three components](https://github.com/cirruslabs/terminal#architecture):

* guest — consumes terminal sessions, pictured as three web UI boxes in Fig. 1.

* host — provides terminal sessions, typically [via an agent](https://github.com/cirruslabs/cirrus-ci-agent), pictured as two server instances in Fig. 1

* server — acts as a rendezvous point for guests and hosts, pictured as `terminal.cirrus-ci.com` server in Fig. 1

The guest is typically implemented in JavaScript (here’s an [example of the integration](https://github.com/cirruslabs/cirrus-ci-web/pull/384) with the Cirrus CI front end), while the host is [available as a Golang package](https://github.com/cirruslabs/terminal/tree/main/pkg/host).

## Security

Cirrus Terminal is an opt-in feature: we understand that not everyone needs it, and this reduces the potential attack surface.

Cirrus Terminal talks to its consumers over HTTPS (using either gRPC or gRPC-Web).

Cirrus Terminal currently does not provide an end-to-end security, meaning that both guest and host trust the Cirrus Terminal server their terminal I/O. Unfortunately having E2E would make some promising features like SSH access impossible to implement (see Future section below) due to the way SSH protocol works.

## Future

Cirrus Terminal is designed with a little bit of SSH protocol in mind, so it’s technically possible to provide access over SSH in the future. Imagine typing:

```bash
ssh task-id@terminal.cirrus-ci.com
```

…in the comfort of your own terminal!

This time we’ve introduced the Cirrus Terminal, a feature that helps you to spend less time debugging and more time writing great software! And [it’s open-source](https://github.com/cirruslabs/terminal) too!

Have you already tried it and how do you like it? Perhaps you have some questions? Don’t hesitate to send us your feedback either [on GitHub](https://github.com/cirruslabs/cirrus-ci-docs/issues/new/choose) or [on Twitter](https://twitter.com/cirrus_labs)!
