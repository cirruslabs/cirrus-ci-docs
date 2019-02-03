# Quick Start

Start by configuring the [Cirrus CI application](https://github.com/marketplace/cirrus-ci) from GitHub Marketplace.

<img src="/assets/images/screenshots/github/marketplace/step1.png" />

Choose a plan for your personal account or for an organization you have admin writes for.

<img src="/assets/images/screenshots/github/marketplace/step2.png" />

GitHub Apps can be installed on all repositories or on repository-by-repository basis for granular access control. For
example, Cirrus CI can be installed only on public repositories and will only have access to these public repositories.
In contrast, classic OAuth Apps [don't have such restrictions](https://developer.github.com/apps/differences-between-apps/#what-can-github-apps-and-oauth-apps-access).  

<img src="/assets/images/screenshots/github/marketplace/step3.png" />

## Post Installation

Once Cirrus CI is installed for a particular repository, a `.cirrus.yml` configuration file should be added to the root of the repository. 
`.cirrus.yml` defines tasks that will be executed for every build for the repository. 

For a simple Node.js project `.cirrus.yml` can look like:

```yaml
container:
  image: node:latest

test_task:
  node_modules_cache:
    folder: node_modules
    fingerprint_script: cat yarn.lock
    populate_script: yarn install
  script: yarn test
```

That's all! After pushing `.cirrus.yml` a build with all the tasks defined in `.cirrus.yml` file will be created.

!!! tip "Zero-config Docker Builds"
    If your repository happened to have a `Dockerfile` in the root, Cirrus CI will attempt to build it even without
    a corresponding `.cirrus.yml` configuration file.

You will see all your Cirrus CI builds on [cirrus-ci.com](https://cirrus-ci.com/) once signing in. 

<img src="/assets/images/screenshots/github/recent-builds.png" />

GitHub status checks for each task will appear on GitHub as well.

<img src="/assets/images/screenshots/github/statuses-branch.png" />

Newly created PRs will also get Cirrus CI's status checks.

<img src="/assets/images/screenshots/github/statuses-pr.png" />

!!! info "Examples"
    Don't forget to check [examples page](/examples) for ready-to-copy examples of `.cirrus.yml` configuration files
    for different languages and build systems.

!!! info "Life of a build"
    Please check [a high level overview of what's happening under the hood](build-life.md) when a changed is pushed
    and [this guide](writing-tasks) to learn more about how to write tasks.
