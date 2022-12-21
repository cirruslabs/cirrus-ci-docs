---
draft: false
date: 2018-03-08
authors:
  - fkorotkov
categories:
  - announcement
  - docker
---

# Introducing Container Builder for Cirrus CI

When Cirrus CI was announced a few months ago Docker support was already pretty sophisticated. It was possible to use any existing Docker container image as an environment to run CI tasks in. But even though Docker is so popular nowadays and there are hundreds of thousands of containers created by community members, in some cases it’s still pretty hard to find a container that has everything installed for your builds. Just remember how many times you’ve seen apt-get install in CI scripts! Every such apt-get install is just a waste of time. Everything should be prebuilt into a container image! And now with Cirrus CI it’s easier than ever before!

<!-- more -->

## Dockerfile as a CI environment

Now there is no need to build and push custom containers so they can be used as an environment to run CI tasks in. Cirrus CI can do it for you! Just specify path to a Dockerfile via dockerfile field for you container declaration in `.cirrus.yml` like this:

```yaml
efficient_task:
  container:
    dockerfile: ci/Dockerfile
  test_script: ...

inefficient_task:
  container:
    image: node:latest
  setup_script:
    - apt-get update
    - apt-get install build-essential
  test_script: ...
```

Cirrus CI will build a container and cache the resulting image based on Dockerfile’s content. On the next build, Cirrus CI will check if a container was already built, and if so, Cirrus CI will instantly start a CI task using the cached image.

Under the hood, for every Dockerfile that is needed to be built, Cirrus CI will create a Docker Build task as [a dependency](https://cirrus-ci.org/guide/writing-tasks/#dependencies). You will see such `build_docker_iamge_HASH` tasks in the UI:

![](/blog/images/dockerfile-as-ci-environment.png)

## Docker Builder for Open Source

Before, only container based builds were available for free to Open Source projects via [Cirrus Cloud Clusters](https://cirrus-ci.org/guide/supported-computing-services/#cirrus-cloud-clusters). We are thrilled to introduce `docker_builder` tasks that are executed in a VM with Docker preinstalled. Now, Open Source projects can easily build and publish Docker images by adding `docker_builder` tasks in their CI pipelines. Here is an example of how Docker Builder can be used to push an image to Docker Hub once there is a release tag created:

```yaml
test_task: ...
lint_task: ...

docker_builder:
  only_if: $CIRRUS_TAG != ''
  depends_on: 
    - test
    - lint
  env:
    DOCKER_USERNAME: ENCRYPTED[...]
    DOCKER_PASSWORD: ENCRYPTED[...]
  build_script: docker build --tag myrepo/foo:$CIRRUS_TAG .
  login_script: docker login --username $DOCKER_USERNAME --password $DOCKER_PASSWORD
  push_script: docker push myrepo/foo:$CIRRUS_TAG
```

Please check [documentation](https://cirrus-ci.org/guide/docker-builder-vm/) for more details. 🤓

We are highly encourage you to [try out Cirrus CI](http://cirrus-ci.org/#/quick-start). It’s free for Open Source projects and very easy to setup!

Follow us on [Twitter](https://twitter.com/cirrus_labs) and if you have any questions don’t hesitate to [ask](http://cirrus-ci.org/#/support).
