---
hide:
  - navigation
---
  
# Examples

Here you can find example configurations per different programming languages/frameworks.

## Android

Cirrus CI has a [set of Docker images ready for Android development](https://hub.docker.com/r/cirrusci/android-sdk/). 
If these images are not the right fit for your project you can always use any custom Docker image with Cirrus CI. For those
images `.cirrus.yml` configuration file can look like:

```yaml
container:
  image: cirrusci/android-sdk:30

check_android_task:
  check_script: ./gradlew check connectedCheck
```

Or like this if a running hardware accelerated emulator is needed for the tests:

```yaml
container:
  image: cirrusci/android-sdk:30
  cpu: 4
  memory: 12G
  kvm: true

check_android_task:
  install_emulator_script:
    sdkmanager --install "system-images;android-30;google_apis;x86"
  create_avd_script:
    echo no | avdmanager create avd --force
      -n emulator
      -k "system-images;android-30;google_apis;x86"
  start_avd_background_script:
    $ANDROID_HOME/emulator/emulator
      -avd emulator
      -no-audio
      -no-boot-anim
      -gpu swiftshader_indirect
      -no-snapshot
      -no-window
  # assemble while emulator is starting
  assemble_instrumented_tests_script:
    ./gradlew assembleDebugAndroidTest
  wait_for_avd_script:
    adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 3; done; input keyevent 82'
  check_script: ./gradlew check connectedCheck
```

!!! info
    Please don't forget to setup [Remote Build Cache](#build-cache) for your Gradle project.
    
### Android Lint

The Cirrus CI annotator supports providing inline reports on PRs and can parse Android Lint reports. Here is an example of an *Android Lint*
task that you can add to your `.cirrus.yml`:

```yaml
task:
  name: Android Lint
  lint_script: ./gradlew lintDebug
  always:
    android-lint_artifacts:
      path: "**/reports/lint-results-debug.xml"
      type: text/xml
      format: android-lint
```

## Bazel

Bazel Team provides a [set of official Docker images with Bazel pre-installed](https://l.gcr.io/google/bazel). Here is
an example of how `.cirrus.yml` can look like for Bazel:

=== "amd64"

    ```yaml
    container:
      image: l.gcr.io/google/bazel:latest
    task:
      build_script: bazel build //...
    ```

=== "arm64"

    ```yaml
    arm_container:
      image: l.gcr.io/google/bazel:latest
    task:
      build_script: bazel build //...
    ```

If these images are not the right fit for your project you can always use any custom Docker image with Cirrus CI.

### Remote Cache

Cirrus CI has [built-in HTTP Cache](guide/writing-tasks.md#http-cache) which is compatible with Bazel's [remote cache](https://github.com/bazelbuild/bazel/blob/master/src/main/java/com/google/devtools/build/lib/remote/README.md).

Here is an example of how Cirrus CI HTTP Cache can be used with Bazel:

=== "amd64"

    ```yaml
    container:
      image: l.gcr.io/google/bazel:latest
    task:
      build_script:
        bazel build
          --spawn_strategy=sandboxed
          --strategy=Javac=sandboxed
          --genrule_strategy=sandboxed
          --remote_http_cache=http://$CIRRUS_HTTP_CACHE_HOST
          //...
    ```

=== "arm64"

    ```yaml
    arm_container:
      image: l.gcr.io/google/bazel:latest
    task:
      build_script:
        bazel build
          --spawn_strategy=sandboxed
          --strategy=Javac=sandboxed
          --genrule_strategy=sandboxed
          --remote_http_cache=http://$CIRRUS_HTTP_CACHE_HOST
          //...
    ```

## C++

Official [GCC Docker images](https://hub.docker.com/_/gcc/) can be used for builds. Here is an example of a `.cirrus.yml` that runs tests:

=== "amd64"

    ```yaml
    container:
      image: gcc:latest
    task:
      tests_script: make tests
    ```

=== "arm64"

    ```yaml
    arm_container:
      image: gcc:latest
    task:
      tests_script: make tests
    ```

## Crystal

Official [Crystal Docker images](https://hub.docker.com/r/crystallang/crystal/) can be used for builds. Here is an example
of a `.cirrus.yml` that caches dependencies and runs tests:

```yaml
container:
  image: crystallang/crystal:latest

spec_task:
  shard_cache:
    fingerprint_script: cat shard.lock
    populate_script: shards install
    folder: lib
  spec_script: crystal spec
```

## Elixir

Official [Elixir Docker images](https://hub.docker.com/_/elixir/) can be used for builds. Here is an example of a `.cirrus.yml` that runs tests:

=== "amd64"

    ```yaml
    test_task:
      container:
        image: elixir:latest
      mix_cache:
        folder: deps
        fingerprint_script: cat mix.lock
        populate_script: mix deps.get
      compile_script: mix compile
      test_script: mix test
    ```

=== "arm64"

    ```yaml
    test_task:
      arm_container:
        image: elixir:latest
      mix_cache:
        folder: deps
        fingerprint_script: cat mix.lock
        populate_script: mix deps.get
      compile_script: mix compile
      test_script: mix test
    ```

## Erlang

Official [Erlang Docker images](https://hub.docker.com/_/erlang/) can be used for builds. Here is an example of a `.cirrus.yml` that runs tests:

=== "amd64"

    ```yaml
    test_task:
      container:
        image: erlang:latest
      rebar3_cache:
        folder: _build
        fingerprint_script: cat rebar.lock
        populate_script: rebar3 compile --deps_only
      compile_script: rebar3 compile
      test_script: rebar3 ct
    ```

=== "arm64"

    ```yaml
    test_task:
      arm_container:
        image: erlang:latest
      rebar3_cache:
        folder: _build
        fingerprint_script: cat rebar.lock
        populate_script: rebar3 compile --deps_only
      compile_script: rebar3 compile
      test_script: rebar3 ct
    ```

## Flutter

Cirrus CI provides a [set of Docker images with Flutter and Dart SDK pre-installed](https://hub.docker.com/r/cirrusci/flutter/).
Here is an example of how `.cirrus.yml` can be written for Flutter:

```yaml
container:
  image: cirrusci/flutter:latest

test_task:
  pub_cache:
    folder: ~/.pub-cache
  test_script: flutter test -machine > report.json
  always:
    report_artifacts:
      path: report.json
      format: flutter
```

If these images are not the right fit for your project you can always use any custom Docker image with Cirrus CI.

### Flutter Web

[Our Docker images with Flutter and Dart SDK pre-installed](https://hub.docker.com/r/cirrusci/flutter/) have special `*-web` tags
with [Chromium](https://www.chromium.org/) pre-installed. You can use these tags to run Flutter Web 

First define a new `chromium` platform in your `dart_test.yaml`:

```yaml
define_platforms:
  chromium:
    name: Chromium
    extends: chrome
    settings:
      arguments: --no-sandbox
      executable:
        linux: chromium
```

Now you'll be able to run tests targeting web via `pub run test test -p chromium`

## Go

The best way to test Go projects is by using [official Go Docker images](https://hub.docker.com/_/golang/). Here is
an example of how `.cirrus.yml` can look like for a project using Go Modules:

=== "amd64"

    ```yaml
    container:
      image: golang:latest
    
    test_task:
      modules_cache:
        fingerprint_script: cat go.sum
        folder: $GOPATH/pkg/mod
      get_script: go get ./...
      build_script: go build ./...
      test_script: go test ./...
    ```

=== "arm64"

    ```yaml
    arm_container:
      image: golang:latest
    
    test_task:
      modules_cache:
        fingerprint_script: cat go.sum
        folder: $GOPATH/pkg/mod
      get_script: go get ./...
      build_script: go build ./...
      test_script: go test ./...
    ```

## GolangCI Lint

We highly recommend to configure some sort of linting for your Go project. One of the options is [GolangCI Lint](https://github.com/golangci/golangci-lint).
The Cirrus CI annotator supports providing inline reports on PRs and can parse GolangCI Lint reports. Here is an example of a *GolangCI Lint*
task that you can add to your `.cirrus.yml`:

=== "amd64"

    ```yaml
    task:
      name: GolangCI Lint
      container:
        image: golangci/golangci-lint:latest
      run_script: golangci-lint run -v --out-format json > lint-report.json
      always:
        golangci_artifacts:
          path: lint-report.json
          type: text/json
          format: golangci
    ```

=== "arm64"

    ```yaml
    task:
      name: GolangCI Lint
      arm_container:
        image: golangci/golangci-lint:latest
      run_script: golangci-lint run -v --out-format json > lint-report.json
      always:
        golangci_artifacts:
          path: lint-report.json
          type: text/json
          format: golangci
    ```

## Gradle

We recommend use of the [official Gradle Docker containers](https://hub.docker.com/_/gradle/) since they have Gradle specific configurations already set up. For example, standard Java containers don't have 
a pre-configured user and as a result don't have `HOME` environment variable presented which makes Gradle complain.

### Caching

To preserve caches between Gradle runs, add a [cache instruction](guide/writing-tasks.md#cache-instruction) as shown below.
The trick here is to clean up `~/.gradle/caches` folder in the very end of a build. Gradle creates some unique nondeterministic
files in `~/.gradle/caches` folder on every run which makes Cirrus CI re-upload the cache *every time*. This way, you get faster builds!

=== "amd64"

    ```yaml
    container:
      image: gradle:jdk11
    
    check_task:
      gradle_cache:
        folder: ~/.gradle/caches
      check_script: gradle check
      cleanup_before_cache_script:
        - rm -rf ~/.gradle/caches/$GRADLE_VERSION/
        - rm -rf ~/.gradle/caches/transforms-1
        - rm -rf ~/.gradle/caches/journal-1
        - rm -rf ~/.gradle/caches/jars-3/*/buildSrc.jar
        - find ~/.gradle/caches/ -name "*.lock" -type f -delete
    ```

=== "arm64"

    ```yaml
    arm_container:
      image: gradle:jdk11
    
    check_task:
      gradle_cache:
        folder: ~/.gradle/caches
      check_script: gradle check
      cleanup_before_cache_script:
        - rm -rf ~/.gradle/caches/$GRADLE_VERSION/
        - rm -rf ~/.gradle/caches/transforms-1
        - rm -rf ~/.gradle/caches/journal-1
        - rm -rf ~/.gradle/caches/jars-3/*/buildSrc.jar
        - find ~/.gradle/caches/ -name "*.lock" -type f -delete
    ```

### Build Cache

Here is how [HTTP Cache](guide/writing-tasks.md#http-cache) can be used with Gradle by adding the following code to `settings.gradle`:

```groovy
ext.isCiServer = System.getenv().containsKey("CIRRUS_CI")
ext.isMasterBranch = System.getenv()["CIRRUS_BRANCH"] == "master"
ext.buildCacheHost = System.getenv().getOrDefault("CIRRUS_HTTP_CACHE_HOST", "localhost:12321")

buildCache {
  local {
    enabled = !isCiServer
  }
  remote(HttpBuildCache) {
    url = "http://${buildCacheHost}/"
    enabled = isCiServer
    push = isMasterBranch
  }
}
```

If your project uses a `buildSrc` directory, the build cache configuration should also be applied to `buildSrc/settings.gradle`.

To do this, put the build cache configuration above into a separate `gradle/buildCacheSettings.gradle` file, then apply it to both your `settings.gradle` and `buildSrc/settings.gradle`.

In `settings.gradle`:

```groovy
apply from: new File(settingsDir, 'gradle/buildCacheSettings.gradle')
```

In `buildSrc/settings.gradle`:

```groovy
apply from: new File(settingsDir, '../gradle/buildCacheSettings.gradle')
```

Please make sure you are running Gradle commands with `--build-cache` flag or have `org.gradle.caching` enabled in `gradle.properties` file.
Here is an example of a `gradle.properties` file that we use internally for all Gradle projects:

```properties
org.gradle.daemon=true
org.gradle.caching=true
org.gradle.parallel=true
org.gradle.configureondemand=true
org.gradle.jvmargs=-Dfile.encoding=UTF-8
```

## JUnit

Here is a `.cirrus.yml` that, parses and uploads JUnit reports at the end of the build:

```yaml
junit_test_task:
  junit_script: <replace this comment with instructions to run the test suites>
  always:
    junit_result_artifacts:
      path: "**/test-results/**.xml"
      format: junit
      type: text/xml
```

If it is running on a pull request, annotations will also be displayed in-line.

## Maven

Official [Maven Docker images](https://hub.docker.com/_/maven/) can be used for building and testing Maven projects:

=== "amd64"

    ```yaml
    container:
      image: maven:latest

    task:
      name: Cirrus CI
      maven_cache:
        folder: ~/.m2
      test_script: mvn test -B
    ```

=== "arm64"

    ```yaml
    arm_container:
      image: maven:latest

    task:
      name: Cirrus CI
      maven_cache:
        folder: ~/.m2
      test_script: mvn test -B
    ```

## MySQL

The [Additional Containers feature](guide/writing-tasks.md#additional-containers) makes it super simple to run the same Docker
MySQL image as you might be running in production for your application. Getting a running instance of the latest GA 
version of MySQL can used with the following six lines in your `.cirrus.yml`:

=== "amd64"

    ```yaml hl_lines="3 4 5 6 7 8"
    container:
      image: golang:latest
      additional_containers:
        - name: mysql
          image: mysql:latest
          port: 3306
          env:
            MYSQL_ROOT_PASSWORD: ""
            MYSQL_ALLOW_EMPTY_PASSWORD: "yes"
    ```

=== "arm64"

    ```yaml hl_lines="3 4 5 6 7 8"
    arm_container:
      image: golang:latest
      additional_containers:
        - name: mysql
          image: mysql:latest
          port: 3306
          env:
            MYSQL_ROOT_PASSWORD: ""
            MYSQL_ALLOW_EMPTY_PASSWORD: "yes"
    ```

With the configuration above MySQL will be available on `localhost:3306`. Use empty password to login as `root` user. 

## Node

Official [NodeJS Docker images](https://hub.docker.com/_/node/) can be used for building and testing Node.JS applications.

### npm

Here is an example of a `.cirrus.yml` that caches `node_modules` based on contents of `package-lock.json` file and runs tests:

=== "amd64"

    ```yaml
    container:
      image: node:latest
    
    test_task:
      node_modules_cache:
        folder: node_modules
        fingerprint_script: cat package-lock.json
        populate_script: npm ci
      test_script: npm test
    ```

=== "arm64"

    ```yaml
    arm_container:
      image: node:latest
    
    test_task:
      node_modules_cache:
        folder: node_modules
        fingerprint_script: cat package-lock.json
        populate_script: npm ci
      test_script: npm test
    ```

### Yarn

Here is an example of a `.cirrus.yml` that caches `node_modules` based on the contents of a `yarn.lock` file and runs tests:

=== "amd64"

    ```yaml
    container:
      image: node:latest
    
    test_task:
      node_modules_cache:
        folder: node_modules
        fingerprint_script: cat yarn.lock
        populate_script: yarn install
      test_script: yarn run test
    ```

=== "arm64"

    ```yaml
    arm_container:
      image: node:latest
    
    test_task:
      node_modules_cache:
        folder: node_modules
        fingerprint_script: cat yarn.lock
        populate_script: yarn install
      test_script: yarn run test
    ```

### Yarn 2

Yarn 2 (also known as Yarn Berry), has a different package cache location (`.yarn/cache`).
To run tests, it would look like this:

=== "amd64"

    ```yaml
    container:
      image: node:latest

    test_task:
      yarn_cache:
        folder: .yarn/cache
        fingerprint_script: cat yarn.lock
      install_script:
        - yarn set version berry
        - yarn install
      test_script: yarn run test
    ```

=== "arm64"

    ```yaml
    arm_container:
      image: node:latest

    test_task:
      yarn_cache:
        folder: .yarn/cache
        fingerprint_script: cat yarn.lock
      install_script:
        - yarn set version berry
        - yarn install
      test_script: yarn run test
    ```

### ESLint Annotations

[ESLint](https://eslint.org/) reports are supported by [Cirrus CI Annotations](https://medium.com/cirruslabs/github-annotations-support-227d179cde31).
This way you can see all the linting issues without leaving the pull request you are reviewing! You'll need to generate an
`ESLint` report file (for example, `eslint.json`) in one of your task's scripts. Then save it as an artifact in `eslint` format:

```yaml
task:
  # boilerplate
  eslint_script: ...
  always:
    eslint_report_artifact:
      path: eslint.json
      format: eslint
```

## Protocol Buffers Linting

Here is an example of how  `*.proto` files can be linted using [Buf CLI](https://buf.build/).

=== "amd64"

    ```yaml
    container:
      image: bufbuild/buf:latest

    task:
      name: Buf Lint
      lint_script: buf lint --error-format=json > lint.report.json
      on_failure:
        report_artifacts:
          path: lint.report.json
          format: buf
    ```

=== "arm64"

    ```yaml
    arm_container:
      image: bufbuild/buf:latest

    task:
      name: Buf Lint
      lint_script: buf lint --error-format=json > lint.report.json
      on_failure:
        report_artifacts:
          path: lint.report.json
          format: buf
    ```

## Python

Official [Python Docker images](https://hub.docker.com/_/python/) can be used for builds. Here is an example of a `.cirrus.yml` 
that caches installed packages based on contents of `requirements.txt` and runs `pytest`:

=== "amd64"

    ```yaml
    container:
      image: python:slim
    
    test_task:
      pip_cache:
        folder: ~/.cache/pip
        fingerprint_script: echo $PYTHON_VERSION && cat requirements.txt
        populate_script: pip install -r requirements.txt
      test_script: pytest
    ```

=== "arm64"

    ```yaml
    arm_container:
      image: python:slim
    
    test_task:
      pip_cache:
        folder: ~/.cache/pip
        fingerprint_script: echo $PYTHON_VERSION && cat requirements.txt
        populate_script: pip install -r requirements.txt
      test_script: pytest
    ```

### Building PyPI Packages  

Also using the Python Docker images, you can run tests if you are making packages for [PyPI](https://pypi.org). Here is an example `.cirrus.yml` for doing so:

=== "amd64"

    ```yaml
    container:
      image: python:slim
    
    build_package_test_task:
      pip_cache:
        folder: ~/.cache/pip
        fingerprint_script: echo $PYTHON_VERSION
        populate_script: python3 -m pip install --upgrade setuptools wheel
      build_package_test_script: python3 setup.py sdist bdist_wheel
    ```

=== "arm64"

    ```yaml
    arm_container:
      image: python:slim
    
    build_package_test_task:
      pip_cache:
        folder: ~/.cache/pip
        fingerprint_script: echo $PYTHON_VERSION
        populate_script: python3 -m pip install --upgrade setuptools wheel
      build_package_test_script: python3 setup.py sdist bdist_wheel
    ```

### Linting

You can easily set up linting with Cirrus CI and flake8, here is an example `.cirrus.yml`:

=== "amd64"

    ```yaml
    lint_task:
      container:
        image: alpine/flake8:latest
      script: flake8 *.py
    ```

=== "arm64"

    ```yaml
    lint_task:
      arm_container:
        image: alpine/flake8:latest
      script: flake8 *.py
    ```

### `Unittest` Annotations

Python Unittest reports are supported by [Cirrus CI Annotations](https://medium.com/cirruslabs/github-annotations-support-227d179cde31).
This way you can see what tests are failing without leaving the pull request you are reviewing! Here is an example
of a `.cirrus.yml` that produces and stores `Unittest` reports:

=== "amd64"

    ```yaml
    unittest_task:
      container:
        image: python:slim
      install_dependencies_script: |
        pip3 install unittest_xml_reporting
      run_tests_script: python3 -m xmlrunner tests
      # replace 'tests' with the module,
      # unittest.TestCase, or unittest.TestSuite
      # that the tests are in
      always:
        upload_results_artifacts:
          path: ./*.xml
          format: junit
          type: text/xml
    ```

=== "arm64"

    ```yaml
    unittest_task:
      arm_container:
        image: python:slim
      install_dependencies_script: |
        pip3 install unittest_xml_reporting
      run_tests_script: python3 -m xmlrunner tests
      # replace 'tests' with the module,
      # unittest.TestCase, or unittest.TestSuite
      # that the tests are in
      always:
        upload_results_artifacts:
          path: ./*.xml
          format: junit
          type: text/xml
    ```

Now you should get annotations for your test results.

## Qodana

[Qodana by JetBrains](https://github.com/JetBrains/Qodana) is a code quality monitoring tool that identifies and suggests fixes for bugs,
security vulnerabilities, duplications, and imperfections. It brings all the smart features you love in the JetBrains IDEs.

Here is an example of `.cirrus.yml` configuration file which will save Qodana's report as an artifact, will parse it and
report as [annotations](guide/writing-tasks.md#artifact-parsing):

```yaml
task:
  name: Qodana
  container:
    image: jetbrains/qodana:latest
  env:
    CIRRUS_WORKING_DIR: /data/project
  generate_report_script:
    - /opt/idea/bin/entrypoint --save-report --report-dir=report
  always:
    results_artifacts:
      path: "report/results/result-allProblems.json"
      format: qodana
```

## Release Assets

Cirrus CI doesn't provide a built-in functionality to upload artifacts on a GitHub release but this functionality can be
added via a script. For a release, Cirrus CI will provide `CIRRUS_RELEASE` environment variable along with `CIRRUS_TAG` 
environment variable. `CIRRUS_RELEASE` indicates release id which can be used to upload assets.

Cirrus CI only requires write access to Check API and doesn't require write access to repository contents because of security 
reasons. That's why you need to [create a personal access token](https://github.com/settings/tokens/new) with full access
to `repo` scope. Once an access token is created, please [create an encrypted variable](guide/writing-tasks.md#encrypted-variables) 
from it and save it to `.cirrus.yml`:

```yaml
env:
  GITHUB_TOKEN: ENCRYPTED[qwerty]
```

Now you can use a script to upload your assets:

```bash
#!/usr/bin/env bash

if [[ "$CIRRUS_RELEASE" == "" ]]; then
  echo "Not a release. No need to deploy!"
  exit 0
fi

if [[ "$GITHUB_TOKEN" == "" ]]; then
  echo "Please provide GitHub access token via GITHUB_TOKEN environment variable!"
  exit 1
fi

file_content_type="application/octet-stream"
files_to_upload=(
  # relative paths of assets to upload
)

for fpath in $files_to_upload
do
  echo "Uploading $fpath..."
  name=$(basename "$fpath")
  url_to_upload="https://uploads.github.com/repos/$CIRRUS_REPO_FULL_NAME/releases/$CIRRUS_RELEASE/assets?name=$name"
  curl -X POST \
    --data-binary @$fpath \
    --header "Authorization: token $GITHUB_TOKEN" \
    --header "Content-Type: $file_content_type" \
    $url_to_upload
done
```

## Ruby

Official [Ruby Docker images](https://hub.docker.com/_/ruby/) can be used for builds.
Here is an example of a `.cirrus.yml` that caches installed gems based on Ruby version,
contents of `Gemfile.lock`, and runs `rspec`:

=== "amd64"

    ```yaml
    container:
      image: ruby:latest
    
    rspec_task:
      bundle_cache:
        folder: /usr/local/bundle
        fingerprint_script:
          - echo $RUBY_VERSION
          - cat Gemfile.lock
        populate_script: bundle install
      rspec_script: bundle exec rspec --format json --out rspec.json
      always:
        rspec_report_artifacts:
          path: rspec.json
          type: text/json
          format: rspec
    ```

=== "arm64"

    ```yaml
    arm_container:
      image: ruby:latest
    
    rspec_task:
      bundle_cache:
        folder: /usr/local/bundle
        fingerprint_script:
          - echo $RUBY_VERSION
          - cat Gemfile.lock
        populate_script: bundle install
      rspec_script: bundle exec rspec --format json --out rspec.json
      always:
        rspec_report_artifacts:
          path: rspec.json
          type: text/json
          format: rspec
    ```

??? tip "Repositories without `Gemfile.lock`"
    When you are not committing `Gemfile.lock` (in Ruby gems repositories, for example)
    you can run `bundle install` (or `bundle update`) in `install_script`
    instead of `populate_script` in `bundle_cache`. Cirrus Agent is clever enough to re-upload
    cache entry only if cached folder has been changed during task execution.
    Here is an example of a `.cirrus.yml` that always runs `bundle install`:

    === "amd64"
    
        ```yaml
        container:
          image: ruby:latest
        
        rspec_task:
          bundle_cache:
            folder: /usr/local/bundle
            fingerprint_script:
              - echo $RUBY_VERSION
              - cat Gemfile
              - cat *.gemspec
          install_script: bundle install # or `update` for the freshest bundle
          rspec_script: bundle exec rspec
        ```

    === "arm64"
    
        ```yaml
        arm_container:
          image: ruby:latest
        
        rspec_task:
          bundle_cache:
            folder: /usr/local/bundle
            fingerprint_script:
              - echo $RUBY_VERSION
              - cat Gemfile
              - cat *.gemspec
          install_script: bundle install # or `update` for the freshest bundle
          rspec_script: bundle exec rspec
        ```

!!! tip "Test Parallelization"
    It's super easy to add intelligent test splitting by using [Knapsack Pro](https://knapsackpro.com/) and [matrix modification](guide/writing-tasks.md#matrix-modification).
    After [setting up Knapsack Pro gem](https://docs.knapsackpro.com/knapsack_pro-ruby/guide/), you can add sharding like this:
    
    ```yaml
    task:
      matrix:
        name: rspec (shard 1)
        name: rspec (shard 2)
        name: rspec (shard 3)
        name: rspec (shard 4)
      bundle_cache:
        folder: /usr/local/bundle
        fingerprint_script: cat Gemfile.lock
        populate_script: bundle install
      rspec_script: bundle exec rake knapsack_pro:rspec
    ```
    
    Which will create four shards that will theoretically **run tests 4x faster** by equally splitting all tests between 
    these four shards.

### RSpec and RuboCop Annotations

Cirrus CI natively supports [RSpec](https://rspec.info/) and [RuboCop](https://rubocop.org/) machine-parsable JSON reports.

To get behavior-driven test annotations, generate and upload a `rspec` artifact from your lint task:

=== "amd64"

    ```yaml
    container:
      image: ruby:latest
    
    task:
      name: RSpec
      bundle_cache:
        folder: /usr/local/bundle
        fingerprint_script:
          - echo $RUBY_VERSION
          - cat Gemfile.lock
        populate_script: bundle install
      script: bundle exec rspec --format json --out rspec.json
      always:
        rspec_artifacts:
          path: rspec.json
          type: text/json
          format: rspec
    ```

=== "arm64"

    ```yaml
    arm_container:
      image: ruby:latest
    
    task:
      name: RSpec
      bundle_cache:
        folder: /usr/local/bundle
        fingerprint_script:
          - echo $RUBY_VERSION
          - cat Gemfile.lock
        populate_script: bundle install
      script: bundle exec rspec --format json --out rspec.json
      always:
        rspec_artifacts:
          path: rspec.json
          type: text/json
          format: rspec
    ```

Generate a `rubocop` artifact to quickly gain context for linter/formatter annotations:

=== "amd64"

    ```yaml
    container:
      image: ruby:latest
    
    task:
      name: RuboCop
      bundle_cache:
        folder: /usr/local/bundle
        fingerprint_script:
          - echo $RUBY_VERSION
          - cat Gemfile.lock
        populate_script: bundle install
      script: bundle exec rubocop --format json --out rubocop.json
      always:
        rubocop_artifacts:
          path: rubocop.json
          type: text/json
          format: rubocop
    ```

=== "arm64"

    ```yaml
    arm_container:
      image: ruby:latest
    
    task:
      name: RuboCop
      bundle_cache:
        folder: /usr/local/bundle
        fingerprint_script:
          - echo $RUBY_VERSION
          - cat Gemfile.lock
        populate_script: bundle install
      script: bundle exec rubocop --format json --out rubocop.json
      always:
        rubocop_artifacts:
          path: rubocop.json
          type: text/json
          format: rubocop
    ```

## Rust

Official [Rust Docker images](https://hub.docker.com/_/rust/) can be used for builds. Here is a basic example of `.cirrus.yml` 
that caches crates in `$CARGO_HOME` based on contents of `Cargo.lock`:

=== "amd64"

    ```yaml
    container:
      image: rust:latest
    
    test_task:
      registry_cache:
        folder: $CARGO_HOME/registry
        fingerprint_script: cat Cargo.lock
      target_cache:
        folder: target
        fingerprint_script:
          - rustc --version
          - cat Cargo.lock
      build_script: cargo build
      test_script: cargo test
      before_cache_script: rm -rf $CARGO_HOME/registry/index
    ```

=== "arm64"

    ```yaml
    arm_container:
      image: rust:latest
    
    test_task:
      registry_cache:
        folder: $CARGO_HOME/registry
        fingerprint_script: cat Cargo.lock
      target_cache:
        folder: target
        fingerprint_script:
          - rustc --version
          - cat Cargo.lock
      build_script: cargo build
      test_script: cargo test
      before_cache_script: rm -rf $CARGO_HOME/registry/index
    ```

!!! tip "Caching Cleanup"

    Please note `before_cache_script` that removes registry index from the cache before uploading it in the end of a successful task. 
    Registry index is [changing very rapidly](https://github.com/rust-lang/crates.io-index) making the cache invalid. `before_cache_script`
    deletes the index and leaves only the required crates for caching.

### Rust Nightly

It is possible to use nightly builds of Rust via an [official `rustlang/rust:nightly` container](https://hub.docker.com/r/rustlang/rust/). 
Here is an example of a `.cirrus.yml` to run tests against the latest stable and nightly versions of Rust:

=== "amd64"

    ```yaml
    test_task:
      matrix:
        - container:
            image: rust:latest
        - allow_failures: true
          container:
            image: rustlang/rust:nightly
      registry_cache:
        folder: $CARGO_HOME/registry
        fingerprint_script: cat Cargo.lock
      target_cache:
        folder: target
        fingerprint_script:
          - rustc --version
          - cat Cargo.lock
      build_script: cargo build
      test_script: cargo test
      before_cache_script: rm -rf $CARGO_HOME/registry/index
    ```

=== "arm64"

    ```yaml
    test_task:
      matrix:
        - arm_container:
            image: rust:latest
        - allow_failures: true
          arm_container:
            image: rustlang/rust:nightly
      registry_cache:
        folder: $CARGO_HOME/registry
        fingerprint_script: cat Cargo.lock
      target_cache:
        folder: target
        fingerprint_script:
          - rustc --version
          - cat Cargo.lock
      build_script: cargo build
      test_script: cargo test
      before_cache_script: rm -rf $CARGO_HOME/registry/index
    ```

??? tip "FreeBSD Caveats"

    Vanila FreeBSD VMs don't set some environment variables required by Cargo for effective caching.
    Specifying `HOME` environment variable to some arbitrarily location should fix caching:

    ```yaml
    freebsd_instance:
      image-family: freebsd-12-0
    
    task:
      name: cargo test (stable)
      env:
        HOME: /tmp # cargo needs it
      install_script: pkg install -y rust
      cargo_cache:
        folder: $HOME/.cargo/registry
        fingerprint_script: cat Cargo.lock
      build_script: cargo build --all
      test_script: cargo test --all --all-targets
      before_cache_script: rm -rf $HOME/.cargo/registry/index
    ```

## XCLogParser

[XCLogParser](https://github.com/spotify/XCLogParser) is a CLI tool that parses Xcode and `xcodebuild`'s logs (`xcactivitylog` files) and produces reports in different formats.

Here is an example of `.cirrus.yml` configuration file which will save XCLogParser's flat JSON report as an artifact, will parse it and report as [annotations](https://cirrus-ci.org/guide/writing-tasks/#artifact-parsing):

```yaml
macos_instance:
  image: big-sur-xcode

task:
  name: XCLogParser
  build_script:
    - xcodebuild -scheme noapp -derivedDataPath ~/dd
  always:
    xclogparser_parse_script:
      - brew install xclogparser
      - xclogparser parse --project noapp --reporter flatJson --output xclogparser.json --derived_data ~/dd
    xclogparser_upload_artifacts:
      path: "xclogparser.json"
      type: text/json
      format: xclogparser
```
