## macOS Virtual Machines

It is possible to run macOS Virtual Machines (the same way one can run [Linux containers](linux.md)) on the macOS Community Cluster. 
Simply use `osx_instance` in your `.cirrus.yml` files:

```yaml
osx_instance:
  image: mojave-xcode

task:
  script: echo "Hello World from macOS!"
```

### List of available images

* `mojave-base` - vanilla macOS with Brew and Command Line Tools pre-installed.
* `mojave-xcode-10.3` - based of `mojave-base` with Xcode and couple other packages pre-installed: 
  `cocoapods`, `fastlane`, `rake` and `xctool`.
* `mojave-xcode-11.3` - based of `mojave-base` with Xcode 11.3 and couple other packages pre-installed: 
  `cocoapods`, `fastlane`, `rake` and `xctool`.
* `mojave-xcode-11.3-flutter` - based of `mojave-xcode-11.3` with pre-installed [Flutter](https://flutter.dev/) and Android SDK/NDK.

Note that there are couple of aliases available for images:

* `mojave-xcode` - point to the latest `mojave-xcode-NN` image.
* `mojave-flutter` - point to the latest `mojave-xcode-NN-flutter` image.

Please refer to the [`osx-images`](https://github.com/cirruslabs/osx-images) repository on how the images were built and
don't hesitate to [create issues](https://github.com/cirruslabs/osx-images/issues) if current images are missing something.

!!! info "Underlying Technology"
    Under the hood Cirrus CI is using [Anka Cloud][anka] hosted on [MacStadium][ms] for
    orchestrating macOS VMs. Please refer to the [Anka documentation][anka] for more details.

[anka]: supported-computing-services.md#anka
[ms]: https://www.macstadium.com/
