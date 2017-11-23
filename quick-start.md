# Quick Start

Start by installing Cirrus CI application from GitHub Marketplace. 

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

Please check [Writing Tasks](docs/writing-tasks.md) guide for more details.

That's all! After pushing `.cirrus.yml` is pushed a build with all the tasks will be created. GitHub status checks for ecah task will appear momentarily.

# Private Repositories
