## macOS Virtual Machines

It is possible to run macOS Virtual Machines (the same way one can run [Linux containers](linux.md)) on the macOS Community Cluster. 
Simply use `osx_instance` in your `.cirrus.yml` files:

```yaml
osx_instance:
  image: catalina-xcode

task:
  script: echo "Hello World from macOS!"
```

### List of available images

* `catalina-base` - vanilla macOS with Brew and Command Line Tools pre-installed.
* `catalina-xcode-NN` - based of `catalina-base` with Xcode NN and couple other packages pre-installed: 
  `cocoapods`, `fastlane`, `rake` and `xctool`.
* `catalina-xcode-NN-flutter` - based of `catalina-xcode-NN` with pre-installed [Flutter](https://flutter.dev/) and Android SDK/NDK.

List of available Xcode versions:

* 11.3.1
* 11.4.1
* 11.5
* 11.6
* 12.0

Note that there are couple of aliases available for images:

* `catalina-xcode` - point to the latest stable `catalina-xcode-NN` image.
* `catalina-flutter` - point to the latest `catalina-xcode-NN-flutter` image.

Please refer to the [`osx-images`](https://github.com/cirruslabs/osx-images) repository on how the images were built and
don't hesitate to [create issues](https://github.com/cirruslabs/osx-images/issues) if current images are missing something.

!!! info "Underlying Technology"
    Under the hood Cirrus CI is using [Anka Cloud][anka] hosted on [MacStadium][ms] for
    orchestrating macOS VMs. Please refer to the [Anka documentation][anka] for more details.

[anka]: supported-computing-services.md#anka
[ms]: https://www.macstadium.com/
