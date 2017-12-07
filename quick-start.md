# Quick Start

Start by installing [Cirrus CI application](https://github.com/apps/cirrus-ci) from GitHub Marketplace. 

Once Cirrus CI is installed for a particular repository `.cirrus.yml` configuration file should be added to the root of the repository. 
`.cirrus.yml` defines tasks that will be executed for every build for the repository. 

For a simple Java project `.cirrus.yml` can look like:

```yaml
container:
  image: gradle:4.3.0-jdk8
  cpu: 8
  memory: 20G
task:
  script: gradle check
```

That's all! After pushing `.cirrus.yml` a build with all the tasks defined in `.cirrus.yml` file will be created. 
GitHub status checks for each task will appear momentarily.

?> Please check [a high level overview of what's happening under the hood](docs/build-life.md) when a changed is pushed
and [this guide](docs/writing-tasks.md) to learn more about how to write tasks.
