# Examples

## Gradle

We recommend to use [official Gradle Docker containers](https://hub.docker.com/_/gradle/) since they have `GRADLE_HOME`
environment variable set up and other Gradle specific configurations. For example, standard `java` containers don't have 
a pre-configured user and as a result don't have `HOME` environment variable presented which upsets Gradle.

### Caching

To preserve caches between Gradle runs simply add a [cache instruction](docs/writing-tasks.md#cache-instruction) as shown below. 
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
    - rm -f ~/.gradle/caches/user-id.txt
    - find ~/.gradle/caches/ -name "*.lock" -type f -delete
```

### Build Cache

Here is how [HTTP Cache](docs/writing-tasks.md#http-cache) can be used with Gradle simply by adding following lines to `settings.gradle`:

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
