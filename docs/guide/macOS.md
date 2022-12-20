## macOS Virtual Machines

It is possible to run M1 macOS Virtual Machines (like how one can run [Linux containers](linux.md)) on the Cirrus Cloud macOS Cluster. 
Use `macos_instance` in your `.cirrus.yml` files:

```yaml
macos_instance:
  image: ghcr.io/cirruslabs/macos-ventura-base:latest

task:
  script: echo "Hello World from macOS!"
```

### Available images

Cirrus CI is using [Tart virtualization](https://github.com/cirruslabs/tart) for running macOS Virtual Machines on Apple Silicon.
Cirrus CI Cloud only allows [images managed and regularly updated by us](https://github.com/orgs/cirruslabs/packages?tab=packages&q=macos)
where with Cirrus CLI you can [run any Tart VM](https://github.com/cirruslabs/tart/blob/main/README.md#ci-integration) on your infrastructure.

Please refer to the [`macos-image-templates`](https://github.com/cirruslabs/macos-image-templates) repository on how the images were built and
don't hesitate to [create issues](https://github.com/cirruslabs/macos-image-templates/issues) if current images are missing something.

!!! info "Underlying Orchestration Technology"
    Under the hood Cirrus CI is using Cirrus CI's own [Persistent Workers](persistent-workers.md). See more details in
    out [blog post](https://medium.com/cirruslabs/new-macos-task-execution-architecture-for-cirrus-ci-604250627c94).
