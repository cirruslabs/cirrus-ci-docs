# Quick Start

Start by configuring [Cirrus CI application](https://github.com/apps/cirrus-ci) from GitHub Marketplace.

<img src="/assets/screenshots/installation/step1.png"/>

And install Cirrus CI for your personal account or for an organization you have admin writes for.

<img src="/assets/screenshots/installation/step2.png"/>

Github Apps can be installed on all repositories or on repository-by-repository basis for granular access control. For
example, Cirrus CI can be installed only on public repositories and will only have access to these public repositories.
In contrast, classic OAuth Apps [doesn't have such restrictions](https://developer.github.com/apps/differences-between-apps/#what-can-github-apps-and-oauth-apps-access).  

<img src="/assets/screenshots/installation/step3.png"/>

Once Cirrus CI is installed for a particular repository `.cirrus.yml` configuration file should be added to the root of the repository. 
`.cirrus.yml` defines tasks that will be executed for every build for the repository. 

For a simple Java project `.cirrus.yml` can look like:

```yaml
container:
  image: gradle:jdk8
  cpu: 4
  memory: 10G
check_task:
  script: gradle check
```

That's all! After pushing `.cirrus.yml` a build with all the tasks defined in `.cirrus.yml` file will be created. 
GitHub status checks for each task will appear momentarily.

<img src="/assets/screenshots/installation/statuses-branch.png"/>

Newly create PRs will also get Cirrus CI's status checks.

<img src="/assets/screenshots/installation/statuses-pr.png"/>

!!! info "Examples"
    Don't forget to check [examples page](/examples.md) for ready-to-copy examples of `.cirrus.yml` configuration files
    for different languages and build systems.

!!! info "Life of a build"
    Please check [a high level overview of what's happening under the hood](build-life.md) when a changed is pushed
    and [this guide](writing-tasks.md) to learn more about how to write tasks.
