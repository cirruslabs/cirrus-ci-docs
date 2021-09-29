Docker Pipe is a way to execute each [instruction](writing-tasks.md#supported-instructions) in its own Docker container
while persisting working directory between each of the containers. For example, you can build your application in 
one container, run some lint tools in another containers and finally deploy your app via CLI from another container.

**No need to create huge containers with every single tool pre-installed!**

A `pipe` can be defined the same way as a `task` with the only difference that [instructions](writing-tasks.md#supported-instructions)
should be grouped under the `steps` field defining a Docker `image` for each step to be executed in. Here is an example of how
we build and validate links for the [Cirrus CI documentation](https://github.com/cirruslabs/cirrus-ci-docs) that you are reading right now:

```yaml
pipe:
  name: Build Site and Validate Links
  steps:
    - image: squidfunk/mkdocs-material:latest
      build_script: mkdocs build
    - image: raviqqe/liche:latest # links validation tool in a separate container
      validate_script: /liche --document-root=site --recursive site/
```

Amount of CPU and memory that a pipe has access to can be configured with `resources` field:

```yaml
pipe:
  resources:
    cpu: 2.5
    memory: 5G
  # ...
```
