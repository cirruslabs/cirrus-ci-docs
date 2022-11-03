---
draft: false
date: 2020-10-07
authors:
  - fkorotkov
categories:
  - announcement
  - cirrus-cli
---

# Cirrus CLI — CI-agnostic tool for running Dockerized tasks

Most Continuous Integration vendors try to lock you not only by providing some unique features that were attractive in the first place but also by making you write hundreds of lines of YAML configuration unique to this particular CI or by making you configure all your scripts in the UI. No wonder it’s always a pain to migrate to another CI and it’s hard to justify the effort! There are so many things to rewrite from one YAML format into another YAML format.

Today we are happy to announce **Cirrus CLI — an [open source](https://github.com/cirruslabs/cirrus-cli) tool to run isolated tasks in any environment with Docker installed. Use one configuration format for running your CI builds** the same way locally on your laptop or remotely in any CI. Read below to learn more about our motivation and technical details or jump right to the [GitHub repository](https://github.com/cirruslabs/cirrus-cli) and try Cirrus CLI for yourself!

<img src="https://raw.githubusercontent.com/cirruslabs/cirrus-cli/master/images/cirrus-cli-demo.gif">

<!-- more -->

## Motivation

When Cirrus Labs was created in 2017 the CI market was kind of stagnating. The most popular CIs on GitHub were not innovating for years and it looked like the whole cloud computing technologies are sprinting when CIs are resting on their laurels. Out of this frustration Cirrus CI was created with a focus to leverage modern clouds and be as efficient as possible by using a [completely new concept of architecting CI systems](https://medium.com/cirruslabs/core-principle-of-continuous-integration-systems-is-obsolete-8d926e17c721). Many things have happened since then and the CI market is not stagnating nowadays! There is a new wave of specialized CIs launched with a focus on fixing the CI problem only for one particular niche: only Android or iOS apps, only a specific framework like Laravel, only for Go applications, etc.

Since launching Cirrus CI we heard from users only positive feedback about Cirrus configuration format: it’s concise, there is no magic happening and at the same time it’s easy for humans to understand even though it’s still YAML (check **What’s Next** section to learn about the upcoming alternative configuration format). Here is an example of `.cirrus.yml` configuration file for a Go project:

```yaml
task:
  env:
    matrix:
      VERSION: 1.15
      VERSION: 1.14
  name: Tests (Go $VERSION)
  container:
    image: golang:$VERSION # official Go Docker image
  modules_cache:
    folder: $GOPATH/pkg/mod
    fingerprint_script: cat go.sum
  get_script: go get ./...
  build_script: go build ./...
  test_script: go test ./...
```

**With Cirrus CLI we want to liberate Cirrus configuration format without a requirement to use Cirrus CI.** Many people are OK with their current CI setup and it’s simply not reasonable to put so much effort into migrating to Cirrus CI to benefit from [some unique features](https://cirrus-ci.org/features/).

With Cirrus CLI it is a very low effort to start using and benefitting from Cirrus configuration format to run your CI builds:

* All Cirrus tasks are executed in **isolated Docker containers** that **will make your CI more stable** and easier to upgrade.

* Run the same tasks locally on your work machine the same way CI is running them to debug issues. **Don’t hear “Works on my machine!” excuses ever after.**

* Easily integrate [**remote caching](https://github.com/cirruslabs/cirrus-cli#caching)** within your current infrastructure.

* Benefit from a **huge amount of [existing examples](https://cirrus-ci.org/examples/)** and read more in **What’s Next** section down below about an upcoming alternative configuration format via Starlark.

## Implementation Details

Traditionally, a CI Agent executes builds from the “outside” by ssh-ing into a VM or a container to execute scripts and save logs. Unlike a traditional CI design, Cirrus Agent that executes tasks is running “inside”. This way the agent has no clue where it’s executed: in a cloud, in a Kubernetes cluster, in a macOS VM or locally in a Docker container. The agent simply executes steps(downloads/uploads caches, runs scripts, streams logs, etc.) and streams back logs and execution results using a gRPC API.

Cirrus CLI simply implements the same gRPC API as Cirrus CI but for local usage:

* Instead of supporting [many compute services](https://cirrus-ci.org/guide/supported-computing-services/) the CLI only uses locally available Docker to run containers.

* Instead of storing logs in a blob storage and streaming live logs via WebSockets the CLI just outputs them to the console.

* Instead of storing caches in a cloud storage the CLI stores caches on disk (there is also an [option to use an HTTP cache](https://github.com/cirruslabs/cirrus-cli#caching)).

There is no need for the CLI to do dozens other things that Cirrus CI does, things like updating GitHub UI, collecting and analyzing build metrics, running tens of thousands tasks simultaneously, checking user permissions, health checking VMs and containers, supporting different cloud APIs, etc.

This simple initial design of the unidirectional communication of the agent though a GRPC API allowed to decouple and bring execution of Cirrus tasks to developer machines and practically any environment where Docker installed.

## What’s Next?

There are many exciting things planned for both Cirrus CLI and Cirrus CI but one of the most groundbreaking things will be a support for a **new configuration format via Starlark**! [Starlark](https://github.com/google/starlark-go) — is a scripting language designed to be embedded in a larger application with a simple syntax which is **basically a subset of Python**. Starlark is pretty popular among modern build systems like Bazel for user-defined behaviors because Starlark is fast, very restrictive and deterministic which makes it ideal for caching and other optimizations and leaves very little room for users to shoot themselves in a leg.

YAML is the standard for CI configurations but unfortunately YAML is pretty limiting at the same time. Each CI vendor tries to add its own syntactic sugar for doing matrix builds, having if statements, making dynamic inclusion/exclusion of some scripts, etc. At some point CI configuration is going out of hand and **people are trying to do imperative programming using a declarative language like YAML! Why to try programming in a language that is no suitable for that!?**

Enough words, let’s check an example of configuring a Go project via Starlark!

```python
load("github.com/cirrus-templates/golang", "detect_tasks")

def main():
  return detect_tasks(versions = ["1.15", "1.14"])
```

**That’s it!** It’s a real programming language with an option to load external templates! Let’s also dive into the `detect_tasks` function:

```python
def detect_tasks(versions=["latest"], env={}):
    all_tasks = [test_task(version, env) for version in versions]
    if fs.exists(".golangci.yml"):
        all_tasks += lint_task(env)
    tag = env["GIT_TAG"] or env["CIRRUS_TAG"]
    if tag and fs.exists(".goreleaser.yml"):
        all_tasks += goreleaser_task(env)
    return all_tasks
```

With a real programming language it is possible to do things that were not possible in YAML with any amount of syntactic sugar. There is logic `indetect_task` method that checks if there is a configuration file in the repository for `golangci-lint` and auto-magically configures a linting task. This external loading will allow to create reusable templates for all teams across the company.

There is no CI build that hasn’t flaked once, you can imagine writing **a failure handler** in Starlark for your tasks that **will check logs for common transient failures specific for your CI process and automatically retry tasks without a need for a human eye** and even send a Slack message with the flake details for an additional investigation later on.

We are very excited about possibilities that template sharing will enable and what teams will do with it!

We are encouraging everyone to try out [Cirrus CLI](https://github.com/cirruslabs/cirrus-cli). You can run it locally or integrated with any CI. A list of tested CI configurations can be found [here](https://github.com/cirruslabs/cirrus-cli/blob/master/INSTALL.md).

And please send us feedback either on [GitHub](https://github.com/cirruslabs/cirrus-cli/issues/new) or on [Twitter](https://twitter.com/cirrus_labs)!
