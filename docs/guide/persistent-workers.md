## Persistent Workers

### Introduction

Cirrus CI pioneered an [idea of directly using compute services](https://medium.com/cirruslabs/core-principle-of-continuous-integration-systems-is-obsolete-8d926e17c721)
instead of requiring users to manage their own infrastructure, configuring servers for running CI jobs, performing upgrades, etc.
Instead, Cirrus CI just [uses APIs of cloud providers](supported-computing-services.md) to create virtual machines or containers on demand. This fundamental
design difference has multiple benefits comparing to more traditional CIs:

1. **Ephemeral environment.** Each Cirrus CI task starts in a fresh VM or a container without any state left by previous tasks.
2. **Infrastructure as code.** All VM versions and container tags are specified in `.cirrus.yml` configuration file in your Git repository.
   For any revision in the past Cirrus tasks can be identically reproduced at any point in time in the future using the exact versions of VMs or container tags specified in `.cirrus.yml` at the particular revision. Just imagine how difficult it is to do a security release for a 6 months old version if your CI environment independently changes.
3. **Predictability and cost efficiency.** Cirrus CI uses elasticity of modern clouds and creates VMs and containers on demand
   only when they are needed for executing Cirrus tasks and deletes them right after. Immediately scale from 0 to hundreds or
   thousands of parallel Cirrus tasks without a need to over provision infrastructure or constantly monitor if your team has reached maximum parallelism of your current CI plan.
   
### What is a Persistent Worker

For some use cases the traditional CI setup is still useful. However, not everything is available in the cloud. For example,
Apple releases new ARM-based products and there is no virtualization yet available for the new hardware. 
Another use case is to test the hardware itself, since not everyone is working on websites and mobile apps after all! For such use cases
it makes sense to go with a traditional CI setup: install some binary on the hardware which will constantly pull for new tasks 
and will execute them one after another.

This is precisely what Persistent Workers for Cirrus CI are: a simple way to run Cirrus tasks beyond cloud!

### Configuration

First, create a persistent workers pool for [your personal account](https://cirrus-ci.com/settings/profile/) or a GitHub organization (`https://cirrus-ci.com/settings/github/<ORGANIZATION>`):

<img src="/assets/images/screenshots/worker-pools.png" />

Once a persistent worker is created, copy registration token of the pool and follow [Cirrus CLI guide](https://github.com/cirruslabs/cirrus-cli/blob/master/PERSISTENT-WORKERS.md)
to configure a host that will be a persistent worker.

Once configured, target task execution on a worker by using `persistent_worker` instance and matching by workers' labels:

```yaml
task:
  persistent_worker:
    labels:
      os: darwin
      arch: arm64
  script: echo "running on-premise"
```

Or remove `labels` filed if you want to target any worker:

```yaml
task:
  persistent_worker: {}
  script: echo "running on-premise"
```

### Resource management

By default, Cirrus CI limits task concurrency to 1 task per each worker. To schedule more tasks on a given worker, [configure it's `resources`](https://github.com/cirruslabs/cirrus-cli/blob/master/PERSISTENT-WORKERS.md#resource-management).

Once done, the worker will be considered resource-aware and will be able to execute concurrently either:

* one resource-less task (a task without `resources:` field)
* multiple resourceful tasks (a task with `resources:` field) as long worker has resources available for these tasks

Note that `labels` matching still takes place for both resource-less and resource-aware tasks.

So, considering a worker with the following configuration:

```yaml
token: "[snip]"

name: "mac-mini-usb-hub"

resources:
  connected-iphones: 4
  connected-ipads: 2
```

It will be able to concurrently execute two of these tasks:

```yaml
task:
  name: Test iPhones and iPads

  persistent_worker:
    resources:
      connected-iphones: 2
      connected-ipads: 2

  script: make test
```

And two of these:

```yaml
task:
  name: Test iPhones only

  persistent_worker:
    resources:
      connected-iphones: 2

  script: make test
```

### Isolation

By default, a persistent worker spawns all the tasks on the same host machine it's being run.

However, using the `isolation` field, a persistent worker can utilize a VM or a container engine to increase the separation between tasks and to unlock the ability to use different operating systems.

#### Tart

To use this isolation type, install the [Tart](https://github.com/cirruslabs/tart) on the persistent worker's host machine.

Here's an example of a configuration that will run the task inside of a fresh macOS virtual machine created from a remote [`ghcr.io/cirruslabs/macos-ventura-base:latest`](https://github.com/cirruslabs/macos-image-templates/pkgs/container/macos-ventura-base) VM image:

```yaml
persistent_worker:
  isolation:
    tart:
      image: ghcr.io/cirruslabs/macos-ventura-base:latest
      user: admin
      password: admin

task:
  script: system_profiler
```

Once the VM spins up, persistent worker will connect to the VM's IP-address over SSH using `user` and `password` credentials and run the latest agent version.

#### Parallels

To use this isolation type, install the [Parallels Desktop](https://www.parallels.com/products/desktop/) on the persistent worker's host machine and create a base VM that will be later cloned for each task.

This base VM needs to:

* be either in a stopped or suspended state
* provide SSH access on port 22

Here's an example of a configuration that will run the task inside of a fresh macOS virtual machine created from the `big-sur-base` base VM:

```yaml
persistent_worker:
  isolation:
    parallels:
      image: big-sur-base
      user: admin
      password: secret
      platform: darwin

task:
  script: system_profiler
```

Once the VM spins up, persistent worker will connect to the VM's IP-address over SSH using `user` and `password` credentials and run the latest agent version targeted for the `platform`.

#### Container

To use this isolation type, install and configure a container engine like [Docker](https://github.com/cirruslabs/cirrus-cli/blob/master/INSTALL.md#docker) or [Podman](https://github.com/cirruslabs/cirrus-cli/blob/master/INSTALL.md#podman) (essentially the ones supported by the [Cirrus CLI](https://github.com/cirruslabs/cirrus-cli)).

Here's an example that runs a task in a separate container with a couple directories from the host machine being accessible:

```yaml
persistent_worker:
  isolation:
    container:
      image: debian:latest
      cpu: 24
      memory: 128G
      volumes:
        - /path/on/host:/path/in/container
        - /tmp/persistent-cache:/tmp/cache:ro

task:
  script: uname -a
```
