# Examples

## Android

Cirrus CI has a [set of Docker images ready for Android development](https://hub.docker.com/r/cirrusci/android-sdk/). 
If these images are not the right fit for your project you can always use any custom Docker image with Cirrus CI. For those
images `.cirrus.yml` configuration file can look like:

```yaml
container:
  image: cirrusci/android-sdk:27

check_android_task:
  check_script: ./gradlew check connectedCheck
```

Or like this if a running emulator is needed for the tests:

```yaml
container:
  image: cirrusci/android-sdk:18
  cpu: 4
  memory: 10G

check_android_task:
  create_device_script: >
    echo no | avdmanager create avd --force \
        -n test \
        -k "system-images;android-18;default;armeabi-v7a"
  start_emulator_background_script: >
    $ANDROID_HOME/emulator/emulator \
        -avd test \
        -no-audio \
        -no-window
  wait_for_emulator_script:
    - adb wait-for-device
    - adb shell input keyevent 82
  check_script: ./gradlew check connectedCheck
```

!!! info
    Please don't forget to setup [Remote Build Cache](#build-cache) for your Gradle project. Or at least [simple folder caching](#gradle-caching).

## Bazel

Cirrus CI provides a [set of Docker images with Bazel pre-installed](https://hub.docker.com/r/cirrusci/bazel/). Here is
an example of how `.cirrus.yml` can look like for Bazel:

```yaml
container:
  image: cirrusci/bazel:latest
task:
  build_script: bazel build //...
```

If these images are not the right fit for your project you can always use any custom Docker image with Cirrus CI.

### Remote Cache

Cirrus CI has [built-in HTTP Cache](guide/writing-tasks.md#http-cache) which is compatible with Bazel's [remote cache](https://github.com/bazelbuild/bazel/blob/master/src/main/java/com/google/devtools/build/lib/remote/README.md).

Here is an example of how Cirrus CI HTTP Cache can be used with Bazel:

```yaml
container:
  image: cirrusci/bazel:latest
task:
  build_script: |
    bazel build \
      --spawn_strategy=remote \
      --strategy=Javac=remote \
      --genrule_strategy=remote \
      --remote_rest_cache=http://$CIRRUS_HTTP_CACHE_HOST \
      //...
```

## C++

Official [GCC Docker images](https://hub.docker.com/_/gcc/) can be used for builds. Here is an example of `.cirrus.yml` that runs tests:

```yaml
container:
  image: gcc:latest
task:
  tests_script: make tests
```

## Flutter

Cirrus CI provides a [set of Docker images with Flutter and Dart SDK pre-installed](https://hub.docker.com/r/cirrusci/flutter/). Here is
an example of how `.cirrus.yml` can look like for Flutter:

```yaml
container:
  image: cirrusci/flutter:latest

test_task:
  pub_cache:
    folder: ~/.pub-cache
  test_script: flutter test
```

If these images are not the right fit for your project you can always use any custom Docker image with Cirrus CI.

## Go

The best way to test Go projects is by using [official Go Docker images](https://hub.docker.com/_/golang/). The only caveat
is to instruct Cirrus CI to run builds in a directory inside `$GOPATH` which is set to `/go` on these official Docker images. 
It can be achieved by providing `CIRRUS_WORKING_DIR` environment variable like in the example below:

```yaml
container:
  image: golang:latest

test_task:
  env:
    CIRRUS_WORKING_DIR: /go/src/github.com/$CIRRUS_REPO_FULL_NAME
  get_script: go get -t -v ./...
  test_script: go test -v ./...
```

## Gradle

We recommend to use [official Gradle Docker containers](https://hub.docker.com/_/gradle/) since they have `GRADLE_HOME`
environment variable set up and other Gradle specific configurations. For example, standard `java` containers don't have 
a pre-configured user and as a result don't have `HOME` environment variable presented which upsets Gradle.

### <a name="gradle-caching"></a>Caching

To preserve caches between Gradle runs simply add a [cache instruction](guide/writing-tasks.md#cache-instruction) as shown below. 
Trick here is to clean up `~/.gradle/caches` folder in the very end of a build. Gradle creates some unique nondeterministic
files in `~/.gradle/caches` folder on every run which breaks Cirrus CI check wherever a cache entry has changed during a build.

```yaml
container:
  image: gradle:jdk8

check_task:
  gradle_cache:
    folder: ~/.gradle/caches
  check_script: gradle check
  cleanup_before_cache_script:
    - rm -rf ~/.gradle/caches/$GRADLE_VERSION/
    - find ~/.gradle/caches/ -name "*.lock" -type f -delete
```

### Build Cache

Here is how [HTTP Cache](guide/writing-tasks.md#http-cache) can be used with Gradle simply by adding following lines to `settings.gradle`:

```groovy
ext.isCiServer = System.getenv().containsKey("CI")
ext.isMasterBranch = System.getenv()["CIRRUS_BRANCH"] == "master"

buildCache {
  local {
    enabled = !isCiServer
  }
  remote(HttpBuildCache) {
    url = 'http://' + System.getenv().getOrDefault("CIRRUS_HTTP_CACHE_HOST", "localhost:12321") + "/"
    enabled = isCiServer
    push = isMasterBranch
  }
}
```

Please make sure you are running Gradle commands with `--build-cache` flag or have `org.gradle.caching` enabled in `gradle.properties` file.
Here is an example of `gradle.properties` file that we use internally for all Gradle projects:

```properties
org.gradle.daemon=true
org.gradle.caching=true
org.gradle.parallel=true
org.gradle.configureondemand=true
org.gradle.jvmargs=-Dfile.encoding=UTF-8
```

## MySQL

[Additional Containers feature](/guide/writing-tasks.md#additional-containers) makes it super simple to run the same Docker
MySQL image as you might be running in production for your application. Getting a running instance of the latest GA 
version of MySQL can be as simple as the following six lines in your `.cirrus.yml`:

```yaml hl_lines="3 4 5 6 7 8"
container:
  image: golang:latest
  additional_containers:
    - name: mysql
      image: mysql:latest
      port: 3306
      env:
        MYSQL_ROOT_PASSWORD: ""
```

With the configuration above MySQL will be available on `localhost:3306`. Use empty password to login as `root` user. 

## Node

Official [Node Docker images](https://hub.docker.com/_/node/) can be used for builds. Here is an example of `.cirrus.yml` that caches `node_modules` 
based on contents of `yarn.lock` lock and runs tests:

```bash
container:
  image: node:latest

test_task:
  node_modules_cache:
    folder: node_modules
    fingerprint_script: cat yarn.lock
    populate_script: yarn install
  test_script: yarn run test
```

## Python

Official [Python Docker images](https://hub.docker.com/_/python/) can be used for builds. Here is an example of `.cirrus.yml` 
that caches installed packages based on contents of `requirements.txt` and runs `pytest`:

```yaml
container:
  image: python:latest

test_task:
  pip_cache:
    folder: ~/.cache/pip
    fingerprint_script: cat requirements.txt
    populate_script: pip install -r requirements.txt
  test_script: pytest
```

## Ruby

Official [Ruby Docker images](https://hub.docker.com/_/ruby/) can be used for builds. Here is an example of `.cirrus.yml` 
that caches installed gems based on contents of `Gemfile.lock` and runs `rspec`:

```yaml
container:
  image: ruby:latest

rspec_task:
  bundle_cache:
    folder: /usr/local/bundle
    fingerprint_script: cat Gemfile.lock
    populate_script: bundle install
  rspec_script: bundle exec rspec
```

!!! tip "Test Palatalization"
    It's super easy to add intelligent test splitting by using [Knapsack Pro](https://knapsackpro.com/) and [matrix modification](/guide/writing-tasks.md#matrix-modification).
    After [setting up Knapsack Pro gem](https://docs.knapsackpro.com/knapsack_pro-ruby/guide/) simply add sharding like this:
    
    ```yaml
    task:
      name:
        matrix:
          - rspec (shard 1)
          - rspec (shard 2)
          - rspec (shard 3)
          - rspec (shard 4)
      bundle_cache:
        folder: /usr/local/bundle
        fingerprint_script: cat Gemfile.lock
        populate_script: bundle install
      rspec_script: bundle exec rake knapsack_pro:rspec
    ```
    
    Which will create four shards that will theoretically **run tests 4x faster** by equaly splitting all tests between 
    these four shards.

## Rust

Official [Rust Docker images](https://hub.docker.com/_/rust/) can be used for builds. Here is a simple example of `.cirrus.yml` 
that caches crates in `$CARGO_HOME` based on contents of `Cargo.lock`:

```yaml
container:
  image: rust:latest

test_task:
  cargo_cache:
    folder: $CARGO_HOME/registry
    fingerprint_script: cat Cargo.lock
  build_script: cargo build
  test_script: cargo test
  before_cache_script: rm -rf $CARGO_HOME/registry/index
```

!!! tip "Caching Cleanup"

    Please note `before_cache_script` that removes registry index from the cache before uploading it in the end of a successful task. 
    Registry index is [changing very rapidly](https://github.com/rust-lang/crates.io-index) making the cache invalid. `before_cache_script`
    deletes the index and leaves just the required crates for caching.

### Rust Nightly

It is possible to use nightly builds of Rust via an [official `rustlang/rust:nightly` container](https://hub.docker.com/r/rustlang/rust/). 
Here is an example of `.cirrus.yml` to run tests against the latest stable and nightly versions of Rust:

```yaml
test_task:
  matrix:
    - container:
        image: rust:latest
    - allow_failures: true
      container:
        image: rustlang/rust:nightly
  cargo_cache:
    folder: $CARGO_HOME/registry
    fingerprint_script: cat Cargo.lock
  build_script: cargo build
  test_script: cargo test
  before_cache_script: rm -rf $CARGO_HOME/registry/index
```
