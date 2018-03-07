Docker Builder is a way for Open Source projects to build and publish Docker Images to Docker Registries of their choice.
In essence, a `docker_builder` is basically a `task` that is executed in a VM with pre-installed Docker. 
`docker_builder` can be defined the same way as a `task`:

```yaml
docker_builder:
  build_script: docker build --tag myrepo/foo:latest .
```

Leveraging features like [Task Dependencies](/guide/writing-tasks.md#depepndencies), [Conditional Execution](/guide/writing-tasks.md#conditional-execution)
and [Encrypted Variables](/guide/writing-tasks.md#encrypted-variables) with a Docker Builder can help building some pretty
complex pipelines.

In the example below, a `docker_builder` will be only executed on a tag creation, once both `test` and `lint` 
tasks have finished successfully:

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

!!! Info
    For more examples please check how we use Docker Builder to build and publish Cirrus CI's Docker Images for [Android](https://github.com/cirruslabs/docker-images-android).
