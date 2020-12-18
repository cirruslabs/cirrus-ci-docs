## Persistent Workers

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

For some use cases the traditional CI setup is still useful. Not everything is available in the cloud! For example,
Apple releases new ARM-based products and there is simply no virtualization yet available for the new hardware. 
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
