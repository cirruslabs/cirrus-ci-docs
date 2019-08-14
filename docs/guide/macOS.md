## macOS Virtual Machines

It is possible to run macOS Virtual Machines (the same way one can run [Linux containers](linux.md)) on the macOS Community Cluster. 
Simply use `osx_instance` in your `.cirrus.yml` files:

```yaml
osx_instance:
  image: mojave-xcode-10.2

task:
  script: echo "Hello World from macOS!"
```

### List of available images

* `mojave-base` - vanilla macOS with Brew and Command Line Tools pre-installed.
* `mojave-xcode-10.1` - based of `mojave-base` with Xcode and couple other packages pre-installed: 
  `cocoapods`, `fastlane`, `rake` and `xctool`.
* `mojave-xcode-10.2` - based of `mojave-base` with Xcode and couple other packages pre-installed: 
  `cocoapods`, `fastlane`, `rake` and `xctool`.
* `mojave-xcode-11` - based of `mojave-base` with Xcode 11 Beta 5 and couple other packages pre-installed: 
  `cocoapods`, `fastlane`, `rake` and `xctool`.
* `mojave-flutter` - based of `mojave-xcode-10.1` with pre-installed [Flutter](https://flutter.dev/) and Android SDK/NDK.
* `mojave-xcode-10.2-flutter` - based of `mojave-xcode-10.2` with pre-installed [Flutter](https://flutter.dev/) and Android SDK/NDK.
* (**Not maintained**) `high-sierra-base` - vanilla macOS with [Homebrew](https://brew.sh) and Command Line Tools pre-installed.
* (**Not maintained**) `high-sierra-xcode-9.4.1` and `high-sierra-xcode-10.0` - based on `high-sierra-base` with Xcode and couple other packages pre-installed: `cocoapods`, `fastlane`, `rake` and `xctool`.

Please refer to the [`osx-images`](https://github.com/cirruslabs/osx-images) repository on how the images were built and
don't hesitate to [create issues](https://github.com/cirruslabs/osx-images/issues) if current images are missing something.

!!! info "Underlying Technology"
    Under the hood Cirrus CI is using [Anka Cloud][anka] hosted on [MacStadium][ms] for
    orchestrating macOS VMs. Please refer to the [Anka documentation][anka] for more details.

[anka]: supported-computing-services.md#anka
[ms]: https://www.macstadium.com/
