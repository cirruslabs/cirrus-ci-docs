Task defines where and how your scripts will be executed. Let's see a line-by-line example of a `.cirrus.yml` configuration file first:

```yaml
test_task:
  container:
    image: gradle:jdk8
    cpu: 4
    memory: 10G
  test_script: gradle test
```

The example above defines a single task that will be scheduled and executed on the Community Cluster using the `gradle:jdk8` Docker image.
Only one user defined script instruction to run `gradle test` will be executed. Pretty simple, isn't it?

A `task` simply defines a [compute service](supported-computing-services.md) to schedule the task on and 
a sequence of [`script`](#script-instruction) and [`cache`](#cache-instruction) instructions that will be executed.

Please read topics below if you want better understand what's doing on in a more complex `.cirrus.yml` configuration file such as this:

```yaml
# global default
container:
  image: node:latest
  
lint_task:      
  node_modules_cache:
    folder: node_modules
    fingerprint_script: cat yarn.lock
    populate_script: yarn install

  test_script: yarn run lint

test_task:
  container:
    matrix:
      image: node:latest
      image: node:8.3.0
      
  node_modules_cache:
    folder: node_modules
    fingerprint_script: cat yarn.lock
    populate_script: yarn install

  test_script: yarn run test

publish_task:
  depends_on: 
    - test 
    - lint
  only_if: $BRANCH == "master"

  node_modules_cache:
    folder: node_modules
    fingerprint_script: cat yarn.lock
    populate_script: yarn install

  publish_script: yarn run publish
```

!!! tip "Task Naming"
    To name a task one can simply use the `name` field. `foo_task` syntax is simply a syntactic sugar. The following two task definitions
    are identical:
    
    ```yaml
    foo_task:
      ...
    
    task:
      name: foo
      ...
    ```

## Script Instruction

A `script` instruction executes commands via `shell` on Unix or `batch` on Windows. A `script` instruction can be named by
adding a name as a prefix. For example `test_script` or `my_very_specific_build_step_script`. Naming script instructions
helps gather more granular information about task execution. Cirrus CI will use it in future to auto-detect performance 
regressions.

Script commands can be specified as a single string value or a list of string values in a `.cirrus.yml` configuration file
like in the example below:

```yaml
check_task:
  compile_script: gradle --parallel classes testClasses
  check_script:
    - echo "Here comes more then one script!"
    - printenv
    - gradle check
```

## Background Script Instruction

A `background_script` instruction is absolutely the same as `script` instruction but Cirrus CI won't wait for the script to finish 
and will continue execution of following instructions.

Background scripts can be useful when something needs to be executed in the background. For example, a database or
some emulators. Traditionally the same effect is achieved by adding `&` to a command like `$: command &`. Problem here 
is that logs from `command` will be mixed into regular logs of the following commands. By using background scripts 
not only logs will be properly saved and displayed, but also `command` itself will be properly killed in the end of a task.

Here is an example of how `background_script` instruction can be used to run an android emulator:

```yaml
android_test_task:
  start_emulator_background_script: emulator -avd test -no-audio -no-window
  wait_for_emulator_to_boot_script: adb wait-for-device
  test_script: gradle test
``` 

## Cache Instruction

A `cache` instruction allows to persist a folder and reuse it during the next execution of the task. A `cache` instruction can be named the same way as `script` instruction.

Here is an example:

```yaml
test_task:
  container:
    image: node:latest
  node_modules_cache:
    folder: node_modules
    fingerprint_script: cat yarn.lock
    populate_script: yarn install
  test_script: yarn run test
```

The `folder` is a *required* field that tells the agent which folder to cache. It should be relative to the working directory, or the root directory of the machine (ex. `node_modules` or `/usr/bin/bundler`).

A `fingerprint_script` is an *optional* field that can specify a script that will be executed and console output of which
will be used as a key for the given cache. By default the task name is used as a fingerprint value.

`populate_script` is an *optional* field that can specify a script that will be executed to populate the cache.
`populate_script` should create the `folder` if it doesn't exist before the `cache` instruction.
If your dependencies are updated often, please pay attention to `fingerprint_script` and make sure it will produce different outputs for different versions of your dependency (ideally just print locked versions of dependencies).

That means the only difference between the example above and below is that `yarn install` will always be executed in the 
example below where in the example above only when `yarn.lock` has changes.

```yaml
test_task:
  container:
    image: node:latest
  node_modules_cache:
    folder: node_modules
    fingerprint_script: cat yarn.lock
  install_script: yarn install
  test_script: yarn run test
```

!!! warning "Caching for Pull Requests"
    Tasks for PRs upload caches to a separate caching namespace to not interfere with caches used by other tasks.
    But such PR tasks **can read** all caches even from the main caching namespace for a repository.

## Execution Behavior of Instructions

By default Cirrus CI executes instructions one after another and stops the overall task execution on the first failure.
Sometimes there might be situations when some scripts should always be executed or some debug information needs to be saved 
on a failure. For such situations the `always` and `on_failure` keywords can be used to group instructions.

```yaml
task:
  test_script: ./run_tests.sh
  on_failure:
    debug_script: ./print_additional_debug_info.sh
  always:
    test_reports_script: ./print_test_reports.sh
```

In the example above, `print_additional_debug_info.sh` script will be executed only on failures to output some additional
debug information. `print_test_reports.sh` on the other hand will be executed both on successful and and failed runs to
print test reports (test reports are always useful! :smile:).

## Environment Variables

Environment variables can be configured under the `env` or `environment` keywords in `.cirrus.yml` files. Here is an example:

```yaml
echo_task:
  env:
    FOO: Bar
  echo_script: echo $FOO
```

Also some default environment variables are pre-defined:

Name | Value / Description
---  | ---
CI | true
CIRRUS_CI | true
CI_NODE_INDEX | Index of the current task within `CI_NODE_TOTAL` tasks
CI_NODE_TOTAL | Total amount of unique tasks for a given `CIRRUS_BUILD_ID` build 
CONTINUOUS_INTEGRATION | true
CIRRUS_BASE_BRANCH | Base branch name if current build was triggered by a PR. For example `master`
CIRRUS_BASE_SHA | Base SHA if current build was triggered by a PR
CIRRUS_BRANCH | Branch name. For example `my-feature`
CIRRUS_BUILD_ID | Unique build ID
CIRRUS_CHANGE_IN_REPO | Git SHA
CIRRUS_CHANGE_MESSAGE | Commit message or PR title and description, depending on trigger event (Non-PRs or PRs respectively).
CIRRUS_DEFAULT_BRANCH | Default repository branch name. For example `master`
CIRRUS_LAST_GREEN_BUILD_ID | Build id of the last successful build on the same branch at the time of the current build creation.
CIRRUS_LAST_GREEN_CHANGE | Corresponding to `CIRRUS_LAST_GREEN_BUILD_ID` SHA (used in [`changesInclude` function](#supported-functions)).
CIRRUS_PR | PR number if current build was triggered by a PR. For example `239`.
CIRRUS_TAG | Tag name if current build was triggered by a new tag. For example `v1.0`
CIRRUS_OS, OS | Host OS. Either `linux`, `windows` or `darwin`.
CIRRUS_TASK_NAME | Task name
CIRRUS_TASK_ID | Unique task ID
CIRRUS_RELEASE | GitHub Release id if current tag was created for a release. Handy for [uploading release assets](../examples.md#release-assets).
CIRRUS_REPO_CLONE_TOKEN | Temporary GitHub access token to perform a clone.
CIRRUS_REPO_NAME | Repository name. For example `my-project`
CIRRUS_REPO_OWNER | Repository owner (an organization or a user). For example `my-organization`
CIRRUS_REPO_FULL_NAME | Repository full name/slug. For example `my-organization/my-project`
CIRRUS_REPO_CLONE_URL | URL used for cloning. For example `https://github.com/my-organization/my-project.git`
CIRRUS_USER_COLLABORATOR | `true` if a user initialized a build is already a contributor to the repository. `false` otherwise.
CIRRUS_USER_PERMISSION | `admin`, `write`, `read` or `none`.
CIRRUS_HTTP_CACHE_HOST | Host and port number on which [local HTTP cache](#http-cache) can be accessed on.

### Behavioral Environment Variables

And some environment variables can be set to control behavior of the Cirrus CI Agent:

Name | Default Value | Description
---  | --- | ---
CIRRUS_CLONE_DEPTH | `0` which will reflect in a full clone of a single branch | Clone depth.
CIRRUS_SHELL | `sh` on Linux/macOS and `cmd.exe` on Windows | Shell that Cirrus CI uses to execute scripts. By default `sh` is used.
CIRRUS_WORKING_DIR | `cirrus-ci-build` folder inside of a system's temporary folder | Working directory where Cirrus CI executes builds. Default to `cirrus-ci-build` folder inside of a system's temporary folder.

## Encrypted Variables

It is possible to securely add sensitive information to a `.cirrus.yml` file. Encrypted variables are only available to
builds initialized or approved by users with write permission to a corresponding repository.

In order to encrypt a variable go to repository's settings page via clicking settings icon ![settings icon](https://storage.googleapis.com/material-icons/external-assets/v4/icons/svg/ic_settings_black_24px.svg)
on a repository's main page (for example `https://cirrus-ci.com/github/my-organization/my-repository`) and follow instructions.

!!! warning
    Only users with `WRITE` permissions can add encrypted variables to a repository.

An encrypted variable will be presented in a form like `ENCRYPTED[qwerty239abc]` which can be safely committed to `.cirrus.yml` file:

```yaml
publish_task:
  environment:
    AUTH_TOKEN: ENCRYPTED[qwerty239abc]
  script: ./publish.sh
```

Cirrus CI encrypts variables with a unique per repository 256-bit encryption key so forks and even repositories within
the same organization cannot re-use them. `qwerty239abc` from the example above is **NOT** the content of your encrypted
variable, it's just an internal ID. No one can brute force your secrets from such ID. In addition, Cirrus CI doesn't know
a relation between an encrypted variable and a repository for which the encrypted variable was created.

## Matrix Modification

Sometimes it's useful to run the same task against different software versions. Or run different batches of tests based
on an environment variable. For cases like these `matrix` modification comes very handy. It's possible to use `matrix`
keyword **only inside of a particular task** to have multiple tasks based on the original one. Each new task will be created
from the original task by replacing the whole `matrix` YAML node with each `matrix`'s children separately.

Let check an example of a `.cirrus.yml`:

```yaml
test_task:
  container:
    matrix:
      image: node:latest
      image: node:8.3.0
  test_script: yarn run test
```

Which will be expanded into:

```yaml
test_task:
  container:
    image: node:latest
  test_script: yarn run test

test_task:
  container:
    image: node:8.3.0
  test_script: yarn run test
```

!!! tip
    `matrix` modification can be used multiple times within a task.

`matrix` modification makes it easy to create some pretty complex testing scenarios like this:

```yaml
test_task:
  container:
    matrix:
      image: node:latest
      image: node:8.3.0
  env:
    matrix:
      COMMAND: test
      COMMAND: lint
  node_modules_cache:
    folder: node_modules
    fingerprint_script:
      - node --version
      - cat yarn.lock
    populate_script: yarn install
  test_script: yarn run $COMMAND
```

## Task Execution Dependencies

Sometimes it might be very handy to execute some tasks only after successful execution of other tasks. For such cases
it is possible to specify task names that a particular task depends. Use `depends_on` keyword to define dependencies:

```yaml
lint_task:
  script: yarn run lint

test_task:
  script: yarn run test

publish_task:
  depends_on: 
    - test
    - lint
  script: yarn run publish
```

!!! tip "Task Names"
    It is possible to specify task name via `name` field. `lint_task` syntax is simply a syntactic sugar that will be
    expanded into: 
    
    ```yaml
    task:
      name: lint
      ...
    ```
    
    Names can be also pretty complex:
    
    
    ```yaml
    task:
      name: test (linux)
      ...
    
    task:
      name: test (windows)
      ...
    
    task:
      name: test (macOS)
      ...
    
    deploy_task:
      depends_on:
        - test (linux)
        - test (windows)
        - test (macOS)
      ...
    ```

## Conditional Task Execution

Some tasks are meant to be created only if a certain condition is met. And some tasks can be skipped in some cases. 
Cirrus CI supports `only_if` and `skip` keywords in order to provide such flexibility:

* `only_if` keyword controls whether or not a task will be created. For example, you may want to publish only changes
  committed to `master` branch.
  ```yaml
  publish_task:
    only_if: $CIRRUS_BRANCH == 'master'
    script: yarn run publish
  ```

* `skip` keyword allows to skip execution of a task and mark it as successful. For example, you may want to skip linting
  if no source files have changed since the last successful run.
  ```yaml
  lint_task:
    skip: !changesInclude(".cirrus.yml", "*.js", "**/*.js")
    script: yarn run lint
  ```

!!! tip "Skip CI Completely"
    Simply include `[skip ci]` or `[ci skip]` in your commit message in order to skip CI execution for a commit completely.
    
    If you push multiple commits at the same time, only commit message of `HEAD` will be checked for `[skip ci]` 
    or `[ci skip]`.

### Supported Operators

Currently only basic operators like `==`, `!=`, `=~`, `!=~`, `&&`, `||` and unary `!` are supported in `only_if` and `skip` expressions.
[Environment variables](#environment-variables) can also be used as usually.

!!! tip "Pattern Matching Example"
    Use `=~` operator for pattern matching.
    
    ```yaml
    check_aggreement_task:
      only_if: $CIRRUS_BRANCH =~ 'pull/.*'
    ```

### Supported Functions

Currently only one function is supported in `only_if` and `skip` expressions. `changesInclude` function allows to check
which files were changed. `changesInclude` behaves differently for PR builds and regular builds:

* For PR builds, `changesInclude` will check the list of files affected by the PR.
* For regular build, `changesInclude` will use `CIRRUS_LAST_GREEN_CHANGE` [environment variable](#environment-variables)
  to determine list of affected files between `CIRRUS_LAST_GREEN_CHANGE` and `CIRRUS_CHANGE_IN_REPO`.

`changesInclude` function can be very useful for skipping some tasks when no changes to sources have been made since the
last successful Cirrus CI build.

```yaml
lint_task:
  skip: !changesInclude(".cirrus.yml", "*.js", "**/*.js")
  script: yarn run lint
```

## Auto-Cancellation of Tasks

Cirrus CI can automatically cancel tasks in case of new pushes to the same branch. By default Cirrus CI auto-cancels 
all tasks for non default branch (for most repositories `master` branch) but this behavior can be changed by specifying
`auto_cancellation` field:

```yaml
task:
  auto_cancellation: $CIRRUS_BRANCH != 'master' && $CIRRUS_BRANCH !=~ 'release/.*'
  ...
```

## Failure Toleration

Sometimes tasks can play a role of sanity checks. For example, a task can check that your library is working with the latest nightly 
version of some dependency package. It will be great to be notified about such failures but it's not necessary to fail the
whole build when a failure occurs. Cirrus CI has the `allow_failures` keyword which will make a task to not affect the overall status of a build.

```yaml
test_nightly_task:
  allow_failures: $SOME_PACKAGE_DEPENDENCY_VERSION == 'nightly'
```

!!! tip "Skipping Notifications"
    You can also skip posting **red statuses** to GitHub via `skip_notifications` field.
    
    ```yaml
    skip_notifications: $SOME_PACKAGE_DEPENDENCY_VERSION == 'nightly'
    ```
    
    It can help to track potential issues overtime without distracting the main workflow.

## HTTP Cache

For the most cases regular caching mechanism where Cirrus CI caches a folder is more than enough. But modern build systems
like [Gradle](https://gradle.org/), [Bazel](https://bazel.build/) and [Pants](https://www.pantsbuild.org/) can take
advantage of remote caching. Remote caching is when a build system uploads and downloads intermediate results of a build 
execution while the build itself is still executing.

Cirrus CI agent starts a local caching server and exposes it via `CIRRUS_HTTP_CACHE_HOST` environments variable. Caching server
supports `GET`, `POST` and `HEAD` requests to upload, download and check presence of artifacts.

!!! info
    If port `12321` is available `CIRRUS_HTTP_CACHE_HOST` will be equal to `localhost:12321`.  

For example running the following command:

```bash
curl -s -X POST --data-binary=@myfolder.tar.gz http://$CIRRUS_HTTP_CACHE_HOST/mykey
```

... has the same effect as a [caching instruction](#cache-instruction) of `myfolder` folder where `sha1sum` of all the 
`myfolder` contents is equal to `mykey`:

```yaml
myfolder_cache:
  folder: myfolder
```

!!! info
    To see how HTTP Cache can be used with Gradle's Build Cache please check [this example](../examples.md#build-cache).
    
## Additional Containers

Sometimes one container is not enough to run a CI build. For example, your application might use a MySQL database
as a storage. In this case you most likely want a MySQL instance running for your tests.

One option here is to pre-install MySQL and use a [`background_script`](#background-script-instruction) to start it. This
approach has some inconveniences like the need to pre-install MySQL by building a custom Docker container.

For such use cases Cirrus CI allows to run additional containers in parallel with the main container that executes a task.
Each additional container is defined under `additional_containers` keyword in `.cirrus.yml`. Each additional container 
should have a unique `name` and specify at least Docker `image` and `port` that this container exposes.

In the example below we use an [official MySQL Docker image](https://hub.docker.com/_/mysql/) that exposes 
the standard MySQL port (3306). Tests will be able to access MySQL instance via `localhost:3306`.

```yaml
container:
  image: golang:1.9.4
  additional_containers:
    - name: mysql
      image: mysql:8
      port: 3306
      cpu: 1.0
      memory: 512Mi
      env:
        MYSQL_ROOT_PASSWORD: ""
```

Additional container can be very handy in many scenarios. Please check [Cirrus CI catalog of examples](../examples.md) for more details.

!!! info "Default Resources"
    By default, each additional container will get `0.5` CPU and `512Mi` of memory. These values can be configured as usual
    via `cpu` and `memory` fields.

!!! warning
    **Note** that `additional_containers` can be used only with [Community Cluster](supported-computing-services.md#community-cluster) 
    or [Google's Kubernetes Engine](supported-computing-services.md#kubernetes-engine).

## Embedded Badges

Cirrus CI provides a way to embed a badge that can represent status of your builds into a ReadMe file or a website.

For example, this is a badge for `cirruslabs/cirrus-ci-web` repository that contains Cirrus CI's front end: [![Passing build badge example](https://api.cirrus-ci.com/github/cirruslabs/cirrus-ci-web.svg)](https://github.com/cirruslabs/cirrus-ci-web)

In order to embed such a check into your ReadMe file or your website, simply use a URL to a badge that looks like this:

```yaml
https://api.cirrus-ci.com/github/<USER OR ORGANIZATION>/<REPOSITORY>.svg
```

If you want a badge for a particular branch, simply use `?branch=<BRANCH NAME>` query parameter (at the end of the URL) like this:

```yaml
https://api.cirrus-ci.com/github/<USER OR ORGANIZATION>/<REPOSITORY>.svg?branch=<BRANCH NAME>
```

If you want a badge for a particular task within the latest finished build, simply use `?task=<TASK NAME>` query parameter (at the end of the URL) like this:

```yaml
https://api.cirrus-ci.com/github/<USER OR ORGANIZATION>/<REPOSITORY>.svg?task=tests
```

You can even pick a specific script instruction within the task with an additional `script=<SCRIPT NAME>` parameter:

```yaml
https://api.cirrus-ci.com/github/<USER OR ORGANIZATION>/<REPOSITORY>.svg?task=build&script=lint
```

### Badges in Markdown

Here is how Cirrus CI's badge can be embeded in a Markdown file:

```markdown
[![Build Status](https://api.cirrus-ci.com/github/<USER OR ORGANIZATION>/<REPOSITORY>.svg)](https://cirrus-ci.com/github/<USER OR ORGANIZATION>/<REPOSITORY>)
```

## Custom Clone Command

By default Cirrus CI uses a [Git client implemented purely in Go](https://github.com/src-d/go-git) to perform a clone of
a single branch with full Git history. It is possible to control clone depth via `CIRRUS_CLONE_DEPTH` [environment variable](#behavioral-environment-variables).

Customizing clone behavior is a simple as overriding `clone_script`. For example, here an override to use a pre-installed
Git client (if your build environment has it) to do a shallow clone of a single branch:

```yaml
task:
  clone_script: >
    if [[ -z "$CIRRUS_PR" ]]; then
      git clone --recursive --branch=$CIRRUS_BRANCH https://x-access-token:${CIRRUS_REPO_CLONE_TOKEN}@github.com/${CIRRUS_REPO_FULL_NAME}.git $CIRRUS_WORKING_DIR
      git reset --hard $CIRRUS_CHANGE_IN_REPO
    else
      git clone --recursive https://x-access-token:${CIRRUS_REPO_CLONE_TOKEN}@github.com/${CIRRUS_REPO_FULL_NAME}.git $CIRRUS_WORKING_DIR
      git fetch origin pull/$CIRRUS_PR/head:pull/$CIRRUS_PR
      git reset --hard $CIRRUS_CHANGE_IN_REPO
    fi
  ...
```

!!! note "`go-git` benefits"
    Using `go-git` made it possible to not require a pre-installed Git from an execution environment. For example, 
    most of `alpine`-based containers doesn't have Git pre-installed. Because of `go-git` you can even use distroless 
    containers with Cirrus CI which don't even have Operation System.
