A `task` defines a sequence of [instructions](#supported-instructions) to execute and an [execution environment](#execution-environment)
to execute these instructions in. Let's see a line-by-line example of a `.cirrus.yml` configuration file first:

```yaml
test_task:
  container:
    image: gradle:jdk11
  test_script: gradle test
```

The example above defines a single task that will be scheduled and executed on the [Linux Community Cluster](linux.md) using the `gradle:jdk11` Docker image.
Only one user-defined [script instruction](#script-instruction) to run `gradle test` will be executed. Pretty simple, isn't it?

Please read the topics below if you want better understand what's doing on in a more complex `.cirrus.yml` configuration file, such as this:

```yaml
# global default
container:
  image: node:latest

task:
  node_modules_cache:
    folder: node_modules
    fingerprint_script: cat yarn.lock
    populate_script: yarn install

  matrix:
    - name: Lint
      lint_script: yarn run lint
    - name: Test
      container:
        matrix:
          - image: node:latest
          - image: node:lts
      test_script: yarn run test
    - name: Publish
      depends_on:
        - Lint
        - Test
      only_if: $BRANCH == "master"
      publish_script: yarn run publish
```

!!! tip "Task Naming"
    To name a task one can use the `name` field. `foo_task` syntax is a syntactic sugar. Separate name
    field is very useful when you want to have a rich task name:

    ```yaml
    task:
      name: Tests (macOS)
      ...
    ```

    **Note:** instructions within a task can only be named via a prefix (e.g. `test_script`).

## Execution Environment

In order to specify where to execute a particular task you can choose from a variety of options by defining one of the
following fields for a `task`:

Field Name                 | Computing Service                                     | Description
-------------------------- | ----------------------------------------------------- | -----------------------
`container`                | [Linux Community Cluster][container]                  | Linux Docker Container
`windows_container`        | [Windows Community Cluster][windows_container]        | Windows Docker Container
`osx_instance`             | [macOS Community Cluster][osx_instance]               | macOS Virtual Machines
`freebsd_instance`         | [FreeBSD Community Cluster][freebsd_instance]         | FreeBSD Virtual Machines
`gce_instance`             | [Google Compute Engine][gce_instance]                 | Linux, Windows and FreeBSD Virtual Machines in your GCP project
`gke_container`            | [Google Kubernetes Engine][gke_container]             | Linux Docker Containers on private GKE cluster
`ec2_instance`             | [Amazon Elastic Compute Cloud][ec2_instance]          | Linux Virtual Machines in your AWS
`eks_instance`             | [Amazon Elastic Container Service][eks_instance]      | Linux Docker Containers on private EKS cluster
`azure_container_instance` | [Azure Container Instances][azure_container_instance] | Linux and Windows Docker Container on Azure
`anka_instance`            | [Anka Build by Veertu][anka_instance]                 | macOS VMs on your Anka Build

[container]: linux.md
[windows_container]: windows.md
[osx_instance]: macOS.md
[freebsd_instance]: FreeBSD.md
[gce_instance]: supported-computing-services.md#compute-engine
[gke_container]: supported-computing-services.md#kubernetes-engine
[ec2_instance]: supported-computing-services.md#ec2
[eks_instance]: supported-computing-services.md#eks
[azure_container_instance]: supported-computing-services.md#azure-container-instances
[anka_instance]: supported-computing-services.md#anka

## Supported Instructions

Each task is essentially a collection of instructions that are executed sequentially. The following instructions are supported:

* [`script`](#script-instruction) instruction to execute a script.
* [`background_script`](#background-script-instruction) instruction to execute a script in a background.
* [`cache`](#cache-instruction) instruction to persist files between task runs.
* [`artifacts`](#artifacts-instruction) instruction to store and expose files created via a task.
* [`file`](#file-instruction) instruction to create a file from an environment variable.

### Script Instruction

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
    - echo "Here comes more than one script!"
    - printenv
    - gradle check
```

**Note:** Each script instruction is executed in a newly created process, therefore environment variables are not preserved between them.

### Background Script Instruction

A `background_script` instruction is absolutely the same as `script` instruction but Cirrus CI won't wait for the script to finish
and will continue execution of further instructions.

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

### Cache Instruction

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

The `folder` is a *required* field that tells the agent which folder to cache. It should be relative to the working directory, or the root directory of the machine (ex. `node_modules` or `/usr/local/bundle`).

A `fingerprint_script` is an *optional* field that can specify a script that will be executed and console output of which
will be used as a key for the given cache. By default the task name is used as a fingerprint value.

After the last `script` instruction for the task succeeds, Cirrus CI will calculate checksum of the cached folder (note that it's unrelated to `fingerprint_script` instruction) and re-upload the cache if it finds any changes.
To avoid a time-costly re-upload, remove volatile files from the cache (for example, in the last `script` instruction of a task).

`populate_script` is an *optional* field that can specify a script that will be executed to populate the cache.
`populate_script` should create the `folder` if it doesn't exist before the `cache` instruction.
If your dependencies are updated often, please pay attention to `fingerprint_script` and make sure it will produce different outputs for different versions of your dependency (ideally just print locked versions of dependencies).

`reupload_on_changes` is an *optional* field that can specify whether Cirrus Agent should check if 
contents of cached `folder` have changed during task execution and reupload a cache entry in case of any changes.
`reupload_on_changes` option is enabled by defaut and Cirrus Agent will detect additions, deletions and modifications
of any files under specified `folder`. All of the detected changes will be logged under `Upload '$CACHE_NAME' cache` instructions for easier debugging of chache invalidations.

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

!!! warning "Scope of cached artifacts"
    Cache artifacts are shared between tasks, so two caches with the same name on e.g. Linux containers and macOS VMs will share the same set of files.
    This may introduce binary incompatibility between caches. To avoid that, add `echo $CIRRUS_OS` into `fingerprint_script` which will distinguish caches based on OS.

### Artifacts Instruction

An `artifacts` instruction allows to store files and expose them in the UI for downloading later. An `artifacts` instruction
can be named the same way as `script` instruction and has only one required `path` field which accepts a [glob pattern](https://en.wikipedia.org/wiki/Glob_(programming))
of files relative to `$CIRRUS_WORKING_DIR` to store. Right now only storing files under [`$CIRRUS_WORKING_DIR` folder](#environment-variables) as artifacts is supported.

In the example below, *Build and Test* task produces two artifacts: `binaries` artifacts with all executables built during a
successful task completion and `junit` artifacts with all test reports regardless of the final task status (more about
that you can learn in the [next section describing execution behavior](#execution-behavior-of-instructions)).

```yaml
build_and_test_task:
  # instructions to build and test
  binaries_artifacts:
    path: "build/*"
  always:
    junit_artifacts:
      path: "**/test-results/**/*.xml"
      type: text/xml
      format: junit
```

!!! tip "URL to the latest artifacts"
    It is possible to refer to the latest artifacts directly (artifacts of the latests **successful** build).
    Use the following link format to download the latest artifact of a particular task:

    ```yaml
    https://api.cirrus-ci.com/v1/artifact/github/<USER OR ORGANIZATION>/<REPOSITORY>/<TASK NAME>/<ARTIFACTS NAME>/<PATH>
    ```

    It is possible to also **download an archive** of all files within an artifact with the following link:

    ```yaml
    https://api.cirrus-ci.com/v1/artifact/github/<USER OR ORGANIZATION>/<REPOSITORY>/<TASK NAME>/<ARTIFACTS NAME>.zip
    ```
    
    By default, Cirrus looks up the latest **successful** build of the default branch for the repository but the branch name
    can be customized via `?branch=<BRANCH>` query paramter. 

#### Artifact Type

If you want the Cirrus CI API to return a mimetype other than `application/octet-stream`, for example if you wanted certain files to download in a way you don't need to change the extension for, you can specify the `type` parameter, for example:

```yaml
  my_task:
    my_dotjar_artifacts:
      path: build/*.jar
      type: application/java-archive
```

A list of some of the basic types supported can be found [here](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Complete_list_of_MIME_types).

#### Artifact Parsing

Cirrus CI supports parsing artifacts in order to extract information that can be presented in the UI for a [better user experience](https://medium.com/cirruslabs/github-annotations-support-227d179cde31).
Use the `format` field of an artifact instruction to specify artifact's format (mimetypes):

```yaml
junit_artifacts:
  path: "**/test-results/**/*.xml"
  type: text/xml
  format: junit
```

Currently, Cirrus CI supports:

* [Android Lint Report format](../examples.md#android-lint)
* [GolangCI Lint's JSON format](../examples.md#golangci-lint)
* [JUnit's XML format](../examples.md#junit)
    * [Python's Unittest format](../examples.md#unittest-annotations)
  
Please [let us know](https://github.com/cirruslabs/cirrus-ci-annotations/issues/new) what kind of formats Cirrus CI should support next!

### File Instruction

A `file` instruction allows to create a file from an environment variable. It is especially useful for situations when
execution environment doesn't have proper shell to use `echo ... >> ...` syntax, for example, within [scratch Docker containers](https://docs.docker.com/samples/library/scratch/).

Here is an example of how to populate Docker config from an [encrypted environment variable](#encrypted-variables):

```yaml
task:
  environment:
    DOCKER_CONFIG: ENCRYPTED[qwerty]
  docker_config_file:
    path: /root/.docker/config
    variable_name: DOCKER_CONFIG
```

### Execution Behavior of Instructions

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

You can reference other environment variables using `$VAR`, `${VAR}` or `%VAR%` syntax:

```yaml
custom_path_task:
  env:
    SDK_ROOT: ${HOME}/sdk
    PATH: ${SDK_ROOT}/bin:${PATH}
  custom_script: sdktool install
```

Environment variables may also be set at the root level of `.cirrus.yml`. In that case, they will be merged with each task's
individual environment variables, but the task level variables always take precedence. For example:

```yaml
env:
  PATH: /sdk/bin:${PATH}

echo_task:
  env:
    PATH: /opt/bin:${PATH}
  echo_script: echo $PATH
```

Will output `/opt/bin:/usr/local/bin:/usr/bin` or similar, but will not include `/sdk/bin` because this root level setting is
ignored.

Also some default environment variables are pre-defined:

Name | Value / Description
---  | ---
CI | true
CIRRUS_CI | true
CI_NODE_INDEX | Index of the current task within `CI_NODE_TOTAL` tasks
CI_NODE_TOTAL | Total amount of unique tasks for a given `CIRRUS_BUILD_ID` build
CONTINUOUS_INTEGRATION | `true`
CIRRUS_API_CREATED | `true` if the current build was created through the [API](../api.md).
CIRRUS_BASE_BRANCH | Base branch name if current build was triggered by a PR. For example `master`
CIRRUS_BASE_SHA | Base SHA if current build was triggered by a PR
CIRRUS_BRANCH | Branch name. For example `my-feature`
CIRRUS_BUILD_ID | Unique build ID
CIRRUS_CHANGE_IN_REPO | Git SHA
CIRRUS_CHANGE_MESSAGE | Commit message or PR title and description, depending on trigger event (Non-PRs or PRs respectively).
CIRRUS_CRON | [Cron Build](#cron-builds) name if builds was triggered by Cron.
CIRRUS_DEFAULT_BRANCH | Default repository branch name. For example `master`
CIRRUS_LAST_GREEN_BUILD_ID | The build id of the last successful build on the same branch at the time of the current build creation.
CIRRUS_LAST_GREEN_CHANGE | Corresponding to `CIRRUS_LAST_GREEN_BUILD_ID` SHA (used in [`changesInclude` function](#supported-functions)).
CIRRUS_PR | PR number if current build was triggered by a PR. For example `239`.
CIRRUS_PR_DRAFT | `true` if current build was triggered by a Draft PR.
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
GITHUB_CHECK_SUITE_ID | Monotonically increasing id of a corresponding [GitHub Check Suite](https://help.github.com/en/articles/about-status-checks#checks) which caused the Cirrus CI build.

### Behavioral Environment Variables

And some environment variables can be set to control behavior of the Cirrus CI Agent:

Name | Default Value | Description
---  | --- | ---
CIRRUS_CLONE_DEPTH | `0` which will reflect in a full clone of a single branch | Clone depth.
CIRRUS_SHELL | `sh` on Linux/macOS/FreeBSD and `cmd.exe` on Windows. Set to `direct` to execute each script directly without wrapping the commands in a shell script. | Shell that Cirrus CI uses to execute scripts. By default `sh` is used.
CIRRUS_WORKING_DIR | `cirrus-ci-build` folder inside of a system's temporary folder | Working directory where Cirrus CI executes builds. Default to `cirrus-ci-build` folder inside of a system's temporary folder.

## Encrypted Variables

It is possible to add encrypted variables to a `.cirrus.yml` file. These variables are decrypted only in builds for commits and pull requests that are made by users with `write` permission or approved by them.

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

??? tip "Organization Level Encrypted Variables"
    Sometimes there might be secrets that are used in almost all repositories of an organization. For example, credentials
    to a [compute service](supported-computing-services.md) where tasks will be executed. In order to create such sharable
    encrypted variable go to organization's settings page via clicking settings icon ![settings icon](https://storage.googleapis.com/material-icons/external-assets/v4/icons/svg/ic_settings_black_24px.svg)
    on an organization's main page (for example `https://cirrus-ci.com/github/my-organization`) and follow instructions
    in *Organization Level Encrypted Variables* section.
    
??? warning "Encrypted Variable for Cloud Credentials"
    In case you use integration with [one of supported computing services](supported-computing-services.md), an encrypted variable
    used to store credentials that Cirrus is using to communicate with the computing service won't be decrypted if used
    in [environment variables](#encrypted-variables). These credentials have too many permissions for most of the cases,
    please create separate credentials with the minimum needed permissions for your specific case.
    
    ```yaml
    gcp_credentials: SECURED[!qwerty]
    
    env:
      CREDENTIALS: SECURED[!qwerty] # won't be decrypted in any case
    ```

??? tip "Skipping Task in Forked Repository"
    In forked repository the decryption of variable fails, which causes failure of task depending on it.
    To avoid this by default, make the sensitive task conditional:

    ```yaml
    task:
      name: Task requiring decrypted variables
      only_if: $CIRRUS_REPO_OWNER == 'my-organization'
      ...
    ```

    Owner of forked repository can re-enable the task, if they have the required sensitive data, by encrypting
    the variable by themselves and editing both the encrypted variable and repo-owner condition
    in the `.cirrus.yml` file.

## Cron Builds

It is possible to configure invocations of re-occurring builds via the well-known Cron expressions. Cron builds can be
configured on a repository's settings page (not in `.cirrus.yml`).

It's possible to configure several cron builds with unique `names` which will be available via `CIRRUS_CRON` [environment variable](#environment-variables).
Each cron build should specify *branch* to trigger new builds for and a cron expression compatible with Quartz. You can use
[this generator](https://www.freeformatter.com/cron-expression-generator-quartz.html) to generate/validate your expressions.

**Note:** Cron Builds are timed with the UTC timezone.

## Matrix Modification

Sometimes it's useful to run the same task against different software versions. Or run different batches of tests based
on an environment variable. For cases like these, the `matrix` modifier comes very handy. It's possible to use `matrix`
keyword **only inside of a particular task** to have multiple tasks based on the original one. Each new task will be created
from the original task by replacing the whole `matrix` YAML node with each `matrix`'s children separately.

Let check an example of a `.cirrus.yml`:

```yaml
test_task:
  container:
    matrix:
      - image: node:latest
      - image: node:lts
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
    image: node:lts
  test_script: yarn run test
```

!!! tip
    The `matrix` modifier can be used multiple times within a task.

The `matrix` modification makes it easy to create some pretty complex testing scenarios like this:

```yaml
task:
  container:
    matrix:
      - image: node:latest
      - image: node:lts
  node_modules_cache:
    folder: node_modules
    fingerprint_script:
      - node --version
      - cat yarn.lock
    populate_script: yarn install
  matrix:
    - name: Build
      build_script: yarn build
    - name: Test
      test_script: yarn run test
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

??? tip "Task Names and Aliases"
    It is possible to specify the task's name via the `name` field. `lint_task` syntax is a syntactic sugar that will be
    expanded into:

    ```yaml
    task:
      name: lint
      ...
    ```

    Names can be also pretty complex:

    ```yaml
    task:
      name: Test Shard $TESTS_SPLIT
      env:
        matrix:
          TESTS_SPLIT: 1/3
          TESTS_SPLIT: 2/2
          TESTS_SPLIT: 3/3
      tests_script: ./.ci/tests.sh
    
    deploy_task:
      only_if: $CIRRUS_BRANCH == 'master'
      depends_on:
        - Test Shard 1/3
        - Test Shard 2/3
        - Test Shard 3/3
      script: ./.ci/deploy.sh
      ...
    ```
    
    Complex task names make it difficult to list and **maintain** all of such task names in your `depends_on` field. In order to 
    make it simpler you can use the `alias` field to have a short simplified name for several tasks to use in `depends_on`.
    
    Here is a modified version of an example above that leverages the `alias` field:
    
    ```yaml hl_lines="3 13"
    task:
      name: Test Shard $TESTS_SPLIT
      alias: Tests
      env:
        matrix:
          TESTS_SPLIT: 1/3
          TESTS_SPLIT: 2/2
          TESTS_SPLIT: 3/3
      tests_script: ./.ci/tests.sh
    
    deploy_task:
      only_if: $CIRRUS_BRANCH == 'master'
      depends_on: Tests
      script: ./.ci/deploy.sh
    ```

## Conditional Task Execution

Some tasks are meant to be created only if a certain condition is met. And some tasks can be skipped in some cases.
Cirrus CI supports the `only_if` and `skip` keywords in order to provide such flexibility:

<!-- markdownlint-disable MD031 -->
<!-- markdownlint-disable MD032 -->
* The `only_if` keyword controls whether or not a task will be created. For example, you may want to publish only changes
  committed to the `master` branch.
  ```yaml
  publish_task:
    only_if: $CIRRUS_BRANCH == 'master'
    script: yarn run publish
  ```

* The `skip` keyword allows to skip execution of a task and mark it as successful. For example, you may want to skip linting
  if no source files have changed since the last successful run.
  ```yaml
  lint_task:
    skip: "!changesInclude('.cirrus.yml', '**.{js,ts}')"
    script: yarn run lint
  ```
<!-- markdownlint-enable MD032 -->
<!-- markdownlint-enable MD031 -->

!!! tip "Skip CI Completely"
    Just include `[skip ci]` or `[ci skip]` in the first line of your commit message in order to skip CI execution for a commit completely.

    If you push multiple commits at the same time, only the first line of the last commit message will be checked for `[skip ci]`
    or `[ci skip]`.
    
    If you open a PR, PR title will be checked for `[skip ci]` or `[ci skip]` instead of the last commit message on the PR branch.

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

Currently only one function is supported in the `only_if` and `skip` expressions. `changesInclude` function allows to check
which files were changed. `changesInclude` behaves differently for PR builds and regular builds:

* For PR builds, `changesInclude` will check the list of files affected by the PR.
* For regular builds, `changesInclude` will use the `CIRRUS_LAST_GREEN_CHANGE` [environment variable](#environment-variables)
  to determine list of affected files between `CIRRUS_LAST_GREEN_CHANGE` and `CIRRUS_CHANGE_IN_REPO`.

`changesInclude` function can be very useful for skipping some tasks when no changes to sources have been made since the
last successful Cirrus CI build.

```yaml
lint_task:
  skip: "!changesInclude('.cirrus.yml', '**.{js,ts}')"
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

## Manual tasks

By default a Cirrus CI task is automatically triggered when all it's [dependency tasks](#task-execution-dependencies)
finished successfully. Sometimes though, it can be very handy to trigger some tasks manually, for example, perform a
deployment to staging for manual testing upon all automation checks have succeeded. In order change the default behavior
please use `trigger_type` field like this:

```yaml
task:
  name: "Staging Deploy"
  trigger_type: manual
  depends_on:
    - Tests (Unit)
    - Tests (Ingegration)
    - Lint
```

You'll be able to manually trigger such paused tasks via Cirrus CI Web UI or directly from GitHub Checks page.

## Task Execution Lock

Some CI tasks perform external operations which are required to be executed one at a time. For example, parallel deploys
to the same environment is usually a bad idea. In order to restrict parallel execution of a certain task within a repository,
you can use `execution_lock` to specify a task's lock key, a unique string that will be used to make sure that any tasks with the same `execution_lock` string
are executed one at a time. Here is an example of how to make sure deployments 
on a specific branch *can not* run in parallel:

```yaml
task:
  name: "Automatic Staging Deploy"
  execution_lock: $CIRRUS_BRANCH
```

You'll be able to manually trigger such paused tasks via the [Cirrus CI Web Dashboard](https://cirrus-ci.com) or directly from the commit's `checks` page on GitHub.

## Required PR Labels

Similar to [manual tasks](#manual-tasks) Cirrus CI can pause execution of tasks until a corresponding PR gets labeled.
This can be particular useful when you'd like to do an initial review before running all unit and integration
tests on every [supported platform](supported-computing-services.md). Use the `required_pr_labels` field to specify
a list of labels a PR requires to have in order to trigger a task. Here is a simple example of `.cirrus.yml` config
that automatically runs a linting tool but requires `initial-review` label being presented in order to run tests:

```yaml
lint_task:
  # ...

test_task:
  required_pr_labels: initial-review
  # ...
```

**Note:** `required_pr_labels` has no effect on tasks created for non-PR builds.

You can also require multiple labels to continue executing the task for even more flexibility:

```yaml
deploy_task:
  required_pr_labels: 
    - initial-review
    - ready-for-staging
  depends_on: build
  # ...
```

In the example above both `initial-review` and `ready-for-staging` labels should be presented on a PR in order to perform
a deployment via `deploy` task.

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
curl -s -X POST --data-binary @myfolder.tar.gz http://$CIRRUS_HTTP_CACHE_HOST/mykey
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
    
!!! tip "Port Mapping"
    It's also possible to map ports of additional containers by using `<HOST_PORT>:<CONTAINER_PORT>` format for the `port` field.
    For example, `port: 80:8080` will map port `8080` of the container to be available on local port `80` within a task.

!!! warning
    **Note** that `additional_containers` can be used only with [Community Cluster](supported-computing-services.md#community-cluster)
    or [Google's Kubernetes Engine](supported-computing-services.md#kubernetes-engine).

## Embedded Badges

Cirrus CI provides a way to embed a badge that can represent status of your builds into a ReadMe file or a website.

For example, this is a badge for `cirruslabs/cirrus-ci-web` repository that contains Cirrus CI's front end: [![Passing build badge example](https://api.cirrus-ci.com/github/cirruslabs/cirrus-ci-web.svg)](https://github.com/cirruslabs/cirrus-ci-web)

In order to embed such a check into a "read-me" file or your website, just use a URL to a badge that looks like this:

```yaml
https://api.cirrus-ci.com/github/<USER OR ORGANIZATION>/<REPOSITORY>.svg
```

If you want a badge for a particular branch, use the `?branch=<BRANCH NAME>` query parameter (at the end of the URL) like this:

```yaml
https://api.cirrus-ci.com/github/<USER OR ORGANIZATION>/<REPOSITORY>.svg?branch=<BRANCH NAME>
```

By default, Cirrus picks the latest build in a final state for the repository or a particular branch if `branch` parameter is specified. It's also possible to explicitly set a concrete build to use with `?buildId=<BUILD ID>` query parameter.

If you want a badge for a particular task within the latest finished build, use the `?task=<TASK NAME>` query parameter (at the end of the URL) like this:

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

## CCTray XML

Cirrus CI supports exporting information about the latest repository builds via the [CCTray XML format](https://cctray.org/).
Use the following URL format with a tool of your choice (such as [CCMenu](http://ccmenu.org/)):

```console
https://api.cirrus-ci.com/github/<USER OR ORGANIZATION>/<REPOSITORY>/cctray.xml
```

**Note:** for private repositories you'll need to configure [access token](../api.md#authorization).
