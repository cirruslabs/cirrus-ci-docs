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
  image: gradle:4.4-jdk8

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

## Node

Official [Node Docker images](https://hub.docker.com/_/node/) can be used for builds. Here is an example of `.cirrus.yml` that caches `node_modules` 
based on contents of `yarn.lock` lock and runs tests:

```bash
container:
  image: node:9.4.0

test_task:
  node_modules_cache:
    folder: node_modules
    fingerprint_script: cat yarn.lock
    populate_script: yarn install
  test_script: yarn run test
```
