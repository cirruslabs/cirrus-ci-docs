## macOS Virtual Machines

It is possible to run M1 macOS Virtual Machines (like how one can run [Linux containers](linux.md)) on the Cirrus Cloud macOS Cluster. 
Use `macos_instance` in your `.cirrus.yml` files:

```yaml
macos_instance:
  image: ghcr.io/cirruslabs/macos-runner:sonoma

task:
  script: echo "Hello World from macOS!"
```

### Available images

Cirrus CI is using [Tart virtualization](https://github.com/cirruslabs/tart) for running macOS Virtual Machines on Apple Silicon.
Cirrus CI Cloud only allows `ghcr.io/cirruslabs/macos-runner:sonoma` image which contains the last 3 versions of Xcode.

!!! info "Underlying Orchestration Technology"
    Under the hood Cirrus CI is using Cirrus CI's own [Persistent Workers](persistent-workers.md). See more details in
    out [blog post](https://medium.com/cirruslabs/new-macos-task-execution-architecture-for-cirrus-ci-604250627c94).
