# macOS Virtual Machines

It is possible to run macOS Virtual Machines. Simply use `osx_instance` in `.cirrus.yml` files:

```yaml
osx_instance:
  image: high-sierra-xcode-9.4.1

task:
  script: ...
```

Please refer to [`osx-images`](https://github.com/cirruslabs/osx-images) repository for a list of all available images and
don't hesitate to [create issues](https://github.com/cirruslabs/osx-images/issues) if current images are missing something.

!!! info "Underlying Technology"
    Under the hood Cirrus CI is using [Anka Cloud hosted on MacStadium](/guide/supported-computing-services.md#anka) for 
    orchestrating macOS VMs. Please refer to [documentation](/guide/supported-computing-services.md#anka) for more details.
