## macOS Virtual Machines

It is possible to run macOS Virtual Machines (like how one can run [Linux containers](linux.md)) on the macOS Community Cluster. 
Use `macos_instance` in your `.cirrus.yml` files:

```yaml
macos_instance:
  image: big-sur-base

task:
  script: echo "Hello World from macOS!"
```

### List of available images

#### macOS Big Sur

* `big-sur-base` - vanilla macOS with Brew and Command Line Tools pre-installed.
* `big-sur-xcode-NN` - based of `catalina-base` with Xcode NN and couple other packages pre-installed: 
  `cocoapods`, `fastlane`, `rake` and `xctool`. [Flutter](https://flutter.dev/) and Android SDK/NDK are also pre-installed.**
  
List of available Xcode versions:

* `big-sur-xcode-12.3`
* `big-sur-xcode-12.4`
* `big-sur-xcode-12.5`
* `big-sur-xcode-13`

Note that there is a `big-sur-xcode` alias available to always reference to the latest stable `big-sur-xcode-NN` image.

#### macOS Catalina

* `catalina-base` - vanilla macOS with Brew and Command Line Tools pre-installed.
* `catalina-xcode-NN` - based of `catalina-base` with Xcode NN and couple other packages pre-installed: 
  `cocoapods`, `fastlane`, `rake` and `xctool`. **Starting from Xcode 12.1 [Flutter](https://flutter.dev/) and Android SDK/NDK are also pre-installed.**
* `catalina-xcode-NN-flutter` (**deprecated** since Xcode 12.1) - based of `catalina-xcode-NN` with pre-installed [Flutter](https://flutter.dev/) and Android SDK/NDK.

List of available Xcode versions:

* `catalina-xcode-11.3.1`
* `catalina-xcode-11.4.1`
* `catalina-xcode-11.5`
* `catalina-xcode-11.6`
* `catalina-xcode-12.0`
* `catalina-xcode-12.1`
* `catalina-xcode-12.2`

Note that there are a couple of aliases available for images:

* `catalina-xcode` - point to the latest stable `catalina-xcode-NN` image.
* `catalina-flutter` - point to the latest image with.

### How images are built

Please refer to the [`osx-images`](https://github.com/cirruslabs/osx-images) repository on how the images were built and
don't hesitate to [create issues](https://github.com/cirruslabs/osx-images/issues) if current images are missing something.

!!! info "Underlying Technology"
    Under the hood Cirrus CI is using Cirrus CI's own [Persistent Workers](persistent-workers.md). See more details in
    out [blog post](https://medium.com/cirruslabs/new-macos-task-execution-architecture-for-cirrus-ci-604250627c94).
