A `task` defines a sequence of [instructions](#supported-instructions) to execute and an [execution environment](#execution-environment)
to execute these instructions in. Let's see a line-by-line example of a `.cirrus.yml` configuration file first:

=== "amd64"

    ```yaml
    test_task:
      container:
        image: openjdk:latest
      test_script: ./gradlew test
    ```

=== "arm64"

    ```yaml
    test_task:
      arm_container:
        image: openjdk:latest
      test_script: ./gradlew test
    ```

The example above defines a single task that will be scheduled and executed on the [Linux Cluster](linux.md) using the `openjdk:latest` Docker image.
Only one user-defined [script instruction](#script-instruction) to run `./gradlew test` will be executed. Not that complex, right?

Please read the topics below if you want better understand what's going on in a more complex `.cirrus.yml` configuration file, such as this:

=== "amd64"

    ``` {: .yaml .annotate }
    task:
      container:
        image: node:latest # (1)
    
      node_modules_cache: # (2)
        folder: node_modules
        fingerprint_script: cat yarn.lock
        populate_script: yarn install
    
      matrix: # (3)
        - name: Lint
          skip: !changesInclude('.cirrus.yml', '**.{js,ts}') # (4)
          lint_script: yarn run lint
        - name: Test
          container:
            matrix: # (5)
              - image: node:latest
              - image: node:lts
          test_script: yarn run test
        - name: Publish
          depends_on:
            - Lint
            - Test
          only_if: $BRANCH == "master" # (6)
          publish_script: yarn run publish
    ```

    1. Use any Docker image from public or [private](linux.md#working-with-private-registries) registries
    2. Use [cache instruction](#cache-instruction) to persist folders based on an arbitrary `fingerprint_script`.
    3. Use [`matrix` modification](#matrix-modification) to produce many similar tasks.
    4. See what kind of files were changes and skip tasks that are not applicable.
       See [`changesInclude`](#supported-functions) and [`changesIncludeOnly`](#supported-functions) documentation for details.
    5. Use nested [`matrix` modification](#matrix-modification) to produce even more tasks.
    6. Completely exclude tasks from execution graph by [any custom condition](#conditional-task-execution).

=== "arm64"

    ``` {: .yaml .annotate }
    task:
      arm_container:
        image: node:latest # (1)
    
      node_modules_cache: # (2)
        folder: node_modules
        fingerprint_script: cat yarn.lock
        populate_script: yarn install
    
      matrix: # (3)
        - name: Lint
          skip: !changesInclude('.cirrus.yml', '**.{js,ts}') # (4)
          lint_script: yarn run lint
        - name: Test
          arm_container:
            matrix: # (5)
              - image: node:latest
              - image: node:lts
          test_script: yarn run test
        - name: Publish
          depends_on:
            - Lint
            - Test
          only_if: $BRANCH == "master" # (6)
          publish_script: yarn run publish
    ```

    1. Use any Docker image from public or [private](linux.md#working-with-private-registries) registries
    2. Use [cache instruction](#cache-instruction) to persist folders based on an arbitrary `fingerprint_script`.
    3. Use [`matrix` modification](#matrix-modification) to produce many similar tasks.
    4. See what kind of files were changes and skip tasks that are not applicable.
       See [`changesInclude`](#supported-functions) and [`changesIncludeOnly`](#supported-functions) documentation for details.
    5. Use nested [`matrix` modification](#matrix-modification) to produce even more tasks.
    6. Completely exclude tasks from execution graph by [any custom condition](#conditional-task-execution).

!!! tip "Task Naming"
    To name a task one can use the `name` field. `foo_task` syntax is a syntactic sugar. Separate name
    field is very useful when you want to have a rich task name:

    ```yaml
    task:
      name: Tests (macOS)
      ...
    ```

    **Note:** instructions within a task can only be named via a prefix (e.g. `test_script`).

!!! tip "Visual Task Creation for Beginners"
    If you are just getting started and prefer a more visual way of creating tasks, there
    is a third-party [Cirrus CI Configuration Builder](https://rdil.rocks/cirrus-builder) for generating YAML config that might be helpful.

## Execution Environment

In order to specify where to execute a particular task you can choose from a variety of options by defining one of the
following fields for a `task`:

Field Name                 | Managed by | Description
-------------------------- | ---------- | -----------------------
`container`                | **us**     | [Linux Docker Container][container]
`arm_container`            | **us**     | [Linux Arm Docker Container][container]
`windows_container`        | **us**     | [Windows Docker Container][windows_container]
`macos_instance`           | **us**     | [macOS Virtual Machines][macos_instance]
`freebsd_instance`         | **us**     | [FreeBSD Virtual Machines][freebsd_instance]
`compute_engine_instance`  | **us**     | [Full-fledged custom VM][compute_engine_instance]
`persistent_worker`        | **you**    | [Use any host on any platform and architecture][persistent_worker]
`gce_instance`             | **you**    | [Linux, Windows and FreeBSD Virtual Machines in your GCP project][gce_instance]
`gke_container`            | **you**    | [Linux Docker Containers on private GKE cluster][gke_container]
`ec2_instance`             | **you**    | [Linux Virtual Machines in your AWS][ec2_instance]
`eks_instance`             | **you**    | [Linux Docker Containers on private EKS cluster][eks_instance]
`azure_container_instance` | **you**    | [Linux and Windows Docker Container on Azure][azure_container_instance]
`oke_instance`             | **you**    | [Linux x86 and Arm Containers on Oracle Cloud][oke_instance]

[container]: linux.md
[windows_container]: windows.md
[macos_instance]: macOS.md
[freebsd_instance]: FreeBSD.md
[compute_engine_instance]: custom-vms.md
[persistent_worker]: persistent-workers.md
[gce_instance]: supported-computing-services.md#compute-engine
[gke_container]: supported-computing-services.md#kubernetes-engine
[ec2_instance]: supported-computing-services.md#ec2
[eks_instance]: supported-computing-services.md#eks
[azure_container_instance]: supported-computing-services.md#azure-container-instances
[oke_instance]: supported-computing-services.md#oracle-cloud

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

??? note "Execution on Windows"
    When executed on Windows via `batch`, Cirrus Agent will wrap each line of the script in a `call` so it's possible to
    fail fast upon first line exiting with non-zero exit code.

    To avoid this "syntactic sugar" just create a script file and execute it.

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

=== "amd64"

    ```yaml
    test_task:
      container:
        image: node:latest
      node_modules_cache:
        folder: node_modules
        reupload_on_changes: false # since there is a fingerprint script
        fingerprint_script:
          - echo $CIRRUS_OS
          - node --version
          - cat package-lock.json
        populate_script: 
          - npm install
      test_script: npm run test
    ```

=== "arm64"

    ```yaml
    test_task:
      arm_container:
        image: node:latest
      node_modules_cache:
        folder: node_modules
        reupload_on_changes: false # since there is a fingerprint script
        fingerprint_script:
          - echo $CIRRUS_OS
          - node --version
          - cat package-lock.json
        populate_script: 
          - npm install
      test_script: npm run test
    ```

Either `folder` or a `folders` field (with a list of folder paths) is *required* and they tell the agent which folder paths to cache.

Folder paths should be generally relative to the working directory (e.g. `node_modules`), with the exception of when only a single folder specified. In this case, it can be also an absolute path (`/usr/local/bundle`).

Folder paths can contain a "glob" pattern to cache multiple files/folders within a working directory (e.g. `**/node_modules` will cache every `node_modules` folder within the working directory).

A `fingerprint_script` and `fingerprint_key` are *optional* fields that can specify either:

* a script, the output of which will be hashed and used as a key for the given cache:

  ```yaml
  node_modules_cache:
    folder: node_modules
    fingerprint_script: cat yarn.lock
  ```

* a final cache key:

  ```yaml
  node_modules_cache:
    folder: node_modules
    fingerprint_key: 2038-01-20
  ```

These two fields are mutually exclusive. By default the task name is used as a fingerprint value.

After the last `script` instruction for the task succeeds, Cirrus CI will calculate checksum of the cached folder (note that it's unrelated to `fingerprint_script` or `fingerprint_key` fields) and re-upload the cache if it finds any changes.
To avoid a time-costly re-upload, remove volatile files from the cache (for example, in the last `script` instruction of a task).

`populate_script` is an *optional* field that can specify a script that will be executed to populate the cache.
`populate_script` should create the `folder` if it doesn't exist before the `cache` instruction.
If your dependencies are updated often, please pay attention to `fingerprint_script` and make sure it will produce different outputs for different versions of your dependency (ideally just print locked versions of dependencies).

`reupload_on_changes` is an *optional* field that can specify whether Cirrus Agent should check if 
contents of cached `folder` have changed during task execution and re-upload a cache entry in case of any changes.
If `reupload_on_changes` option is not set explicitly then it will be set to `false` if `fingerprint_script` or `fingerprint_key` is presented and `true` otherwise.
Cirrus Agent will detect additions, deletions and modifications of any files under specified `folder`. All of the detected changes will be
logged under `Upload '$CACHE_NAME' cache` instructions for easier debugging of cache invalidations.

That means the only difference between the example above and below is that `yarn install` will always be executed in the
example below where in the example above only when `yarn.lock` has changes.

=== "amd64"

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

=== "arm64"

    ```yaml
    test_task:
      arm_container:
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
    This may introduce binary incompatibility between caches. To avoid that, add `echo $CIRRUS_OS` into `fingerprint_script` or use `$CIRRUS_OS` in `fingerprint_key`, which will distinguish caches based on OS.

#### Manual cache upload

Normally caches are uploaded at the end of the task execution. However, you can override the default behavior and upload them earlier.

To do this, use the `upload_caches` instruction, which uploads a list of caches passed to it once executed:

=== "amd64"

    ```yaml
    test_task:
      container:
        image: node:latest
      node_modules_cache:
        folder: node_modules
      upload_caches:
        - node_modules
      install_script: yarn install
      test_script: yarn run test
      pip_cache:
        folder: ~/.cache/pip
    ```

=== "arm64"

    ```yaml
    test_task:
      arm_container:
        image: node:latest
      node_modules_cache:
        folder: node_modules
      upload_caches:
        - node_modules
      install_script: yarn install
      test_script: yarn run test
      pip_cache:
        folder: ~/.cache/pip
    ```

Note that `pip` cache won't be uploaded in this example: using `upload_caches` disables the default behavior where all caches are automatically uploaded at the end of the task, so if you want to upload `pip` cache too, you'll have to either:

* extend the list of uploaded caches in the first `upload_caches` instruction
* insert a second `upload_caches` instruction that specifically targets `pip` cache

### Artifacts Instruction

An `artifacts` instruction allows to store files and expose them in the UI for downloading later. An `artifacts` instruction
can be named the same way as `script` instruction and has only one required `path` field which accepts a [glob pattern](https://en.wikipedia.org/wiki/Glob_(programming))
of files relative to `$CIRRUS_WORKING_DIR` to store. Right now only storing files under [`$CIRRUS_WORKING_DIR` folder](#environment-variables) as artifacts is supported with a total size limit of 1G for a free task and with no limit on your own infrastructure.

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
      path: "**/test-results/**.xml"
      format: junit
```

??? tip "URLs to the artifacts"
    #### Latest build artifacts

    It is possible to refer to the latest artifacts directly (artifacts of the latest **successful** build).
    Use the following link format to download the latest artifact of a particular task:

    ```
    https://api.cirrus-ci.com/v1/artifact/github/<USER OR ORGANIZATION>/<REPOSITORY>/<TASK NAME OR ALIAS>/<ARTIFACTS_NAME>/<PATH>
    ```

    It is possible to also **download an archive** of all files within an artifact with the following link:

    ```
    https://api.cirrus-ci.com/v1/artifact/github/<USER OR ORGANIZATION>/<REPOSITORY>/<TASK NAME OR ALIAS>/<ARTIFACTS_NAME>.zip
    ```
    
    By default, Cirrus looks up the latest **successful** build of the default branch for the repository but the branch name
    can be customized via `?branch=<BRANCH>` query parameter.

    #### Current build artifacts

    It is possible to refer to the artifacts of the current build directly:

    ```
    https://api.cirrus-ci.com/v1/artifact/build/<CIRRUS_BUILD_ID>/<ARTIFACTS_NAME>.zip
    ```

    Note that if several tasks are uploading artifacts with the same name then the ZIP archive from the above link will
    contain merged content of all artifacts. It's also possible to refer to an artifact of a particular task within a build
    by name:

    ```
    https://api.cirrus-ci.com/v1/artifact/build/<CIRRUS_BUILD_ID>/<TASK NAME OR ALIAS>/<ARTIFACTS_NAME>.zip
    ```
    
    It is also possible to download artifacts given a task id directly:
    
    ```
    https://api.cirrus-ci.com/v1/artifact/task/<CIRRUS_TASK_ID>/<ARTIFACTS_NAME>.zip
    ```

    It's also possible to download a particular file of an artifact and not the whole archive by using `<ARTIFACTS_NAME>/<PATH>`
    instead of `<ARTIFACTS_NAME>.zip`.

#### Artifact Type

By default, Cirrus CI will try to guess mimetype of files in artifacts by looking at their extensions. In case when artifacts
don't have extensions, it's possible to explicitly set the `Content-Type` via `type` field:

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
  path: "**/test-results/**.xml"
  type: text/xml
  format: junit
```

Currently, Cirrus CI supports:

* [Android Lint Report format](../examples.md#android-lint)
* [GolangCI Lint's JSON format](../examples.md#golangci-lint)
* [JUnit's XML format](../examples.md#junit)
    * [Python's Unittest format](../examples.md#unittest-annotations)
* [XCLogParser](../examples.md#xclogparser)
* [JetBrains Qodana](../examples.md#qodana)
* [Buf CLI for Protocol Buffers](../examples.md#protocol-buffers-linting)

Please [let us know](https://github.com/cirruslabs/cirrus-ci-annotations/issues/new) what kind of formats Cirrus CI should support next!

### File Instruction

A `file` instruction allows to create a file from an environment variable. It is especially useful for situations when
execution environment doesn't have proper shell to use `echo ... >> ...` syntax, for example, within [scratch Docker containers](https://docs.docker.com/samples/library/scratch/).

Here is an example of how to populate Docker config from an [encrypted environment variable](#encrypted-variables):

```yaml
task:
  environment:
    DOCKER_CONFIG_JSON: ENCRYPTED[qwerty]
  docker_config_file:
    path: /root/.docker/config.json
    variable_name: DOCKER_CONFIG_JSON
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
CIRRUS_CHANGE_TITLE | First line of `CIRRUS_CHANGE_MESSAGE`
CIRRUS_CPU | Amount of CPUs requested by the task. `CIRRUS_CPU` value is integer and rounded up for tasks that requested non-interger amount of CPUs. 
CIRRUS_CRON | [Cron Build](#cron-builds) name configured in the repository settings if this build was triggered by Cron. For example, `nightly`.
CIRRUS_DEFAULT_BRANCH | Default repository branch name. For example `master`
CIRRUS_DOCKER_CONTEXT | Docker build's context directory to use for [Dockerfile as a CI environment](docker-builder-vm.md#dockerfile-as-a-ci-environment). Defaults to project's root directory.
CIRRUS_LAST_GREEN_BUILD_ID | The build id of the last successful build on the same branch at the time of the current build creation.
CIRRUS_LAST_GREEN_CHANGE | Corresponding to `CIRRUS_LAST_GREEN_BUILD_ID` SHA (used in [`changesInclude`](#supported-functions) and [`changesIncludeOnly`](#supported-functions) functions).
CIRRUS_PR | PR number if current build was triggered by a PR. For example `239`.
CIRRUS_PR_DRAFT | `true` if current build was triggered by a Draft PR.
CIRRUS_PR_LABELS | comma separated list of PR's labels if current build was triggered by a PR.
CIRRUS_TAG | Tag name if current build was triggered by a new tag. For example `v1.0`
CIRRUS_OIDC_TOKEN | OpenID Token issued by `https://oidc.cirrus-ci.com` with audience set to `https://cirrus-ci.com/github/$CIRRUS_REPO_OWNER` (can be changed via `$CIRRUS_OIDC_TOKEN_AUDIENCE`). Please refer to [Cirrus CI OpenID Configuration](https://oidc.cirrus-ci.com/.well-known/openid-configuration) for the set of all supported claims.
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
CIRRUS_ENV | Path to a file, by writing to which you can [set task-wide environment variables](tips-and-tricks.md#setting-environment-variables-from-scripts).
CIRRUS_ENV_SENSITIVE | Set to `true` to mask all variable values written to the `CIRRUS_ENV` file in the console output

### Behavioral Environment Variables

And some environment variables can be set to control behavior of the Cirrus CI Agent:

| Name                       | Default Value                                                                                                                                          | Description                                                                                                                                                                                                                                                                                                                                                                                                         |
|----------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| CIRRUS_CLONE_DEPTH         | `0` which will reflect in a full clone of a single branch                                                                                              | Clone depth.                                                                                                                                                                                                                                                                                                                                                                                                        |
| CIRRUS_CLONE_SUBMODULES    | `false`                                                                                                                                                | Set to `true` to clone submodules recursively.                                                                                                                                                                                                                                                                                                                                                                      |
| CIRRUS_LOG_TIMESTAMP       | `false`                                                                                                                                                | Indicate Cirrus Agent to prepend timestamp to each line of logs.                                                                                                                                                                                                                                                                                                                                                    |
| CIRRUS_OIDC_TOKEN_AUDIENCE | not set                                                                                                                                                | Allows to override `aud` claim for `CIRRUS_OIDC_TOKEN`.                                                                                                                                                                                                                                                                                                                                                             |
| CIRRUS_SHELL               | `sh` on Linux/macOS/FreeBSD and `cmd.exe` on Windows. Set to `direct` to execute each script directly without wrapping the commands in a shell script. | Shell that Cirrus CI uses to execute scripts. By default `sh` is used.                                                                                                                                                                                                                                                                                                                                              |
| CIRRUS_VOLUME              | `/tmp`                                                                                                                                                 | Defines a path for a temporary volume to be mounted into instances running in a Kubernetes cluster. This volume is mounted into all additional containers and is persisted between steps of a `pipe`.                                                                                                                                                                                                               |
| CIRRUS_WORKING_DIR         | `cirrus-ci-build` folder inside of a system's temporary folder                                                                                         | Working directory where Cirrus CI executes builds. Default to `cirrus-ci-build` folder inside of a system's temporary folder.                                                                                                                                                                                                                                                                                       |
| CIRRUS_ESCAPING_PROCESSES  | not set                                                                                                                                                | Set this variable to prevent the agent from terminating the processes spawned in each non-background instruction after that instruction ends. By default, the agent tries it's best to garbage collect these processes and their standard input/output streams. It's generally better to use a [Background Script Instruction](#background-script-instruction) instead of this variable to achieve the same effect. |
| CIRRUS_WINDOWS_ERROR_MODE  | not set                                                                                                                                                | Set this value to force all processes spawned by the agent to call the equivalent of [`SetErrorMode()`](https://docs.microsoft.com/en-us/windows/win32/api/errhandlingapi/nf-errhandlingapi-seterrormode) with the provided value (for example, `0x8001`) before beginning their execution.                                                                                                                         |
| CIRRUS_VAULT_URL           | not set                                                                                                                                                | Address of the Vault server expressed as a URL and port (for example, `https://vault.example.com:8200/`), see [HashiCorp Vault Support](#hashicorp-vault-support).                                                                                                                                                                                                                                                  |
| CIRRUS_VAULT_NAMESPACE     | not set                                                                                                                                                | A [Vault Enterprise Namespace](https://developer.hashicorp.com/vault/docs/enterprise/namespaces) to use when authenticating and reading secrets from Vault.                                                                                                                                                                                                                                                         |
| CIRRUS_VAULT_AUTH_PATH     | `jwt`                                                                                                                                    | Alternative auth method mount point, in case it was mounted to a non-default path.                                                                                                                                                                                                                                                                                                                                  |
| CIRRUS_VAULT_ROLE          | not set                                                                                                                                                | Auth method-specific role to use (see [JWT/OIDC Auth Method](https://developer.hashicorp.com/vault/api-docs/auth/jwt#create-role), for example).                                                                                                                                                                                                                                                                    |

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

### HashiCorp Vault support

In addition to using Cirrus CI for managing secrets, it is possible to retrieve secrets from [HashiCorp Vault](https://www.vaultproject.io/).

You will need to configure a [JWT authentication method](https://developer.hashicorp.com/vault/docs/auth/jwt#jwt-authentication) and point it to the Cirrus CI's OIDC discovery URL: `https://oidc.cirrus-ci.com`.

This ensures that a cryptographic JWT token (`CIRRUS_OIDC_TOKEN`) that each Cirrus CI's task get assigned will be verified by your Vault installation.

From the Cirrus CI's side, use the `CIRRUS_VAULT_URL` environment variable to point Cirrus Agent at your vault and configure [other Vault-specific variables](#behavioral-environment-variables), if needed. Note that it's not required for `CIRRUS_VAULT_URL` to be publicly available since Cirrus CI can orchestrate tasks on your infrastructure. Only Cirrus Agent executing a task from within an [execution environment](#execution-environment) needs access to your Vault.

Once done, you will be able to use the `VAULT[path/to/secret selector]` syntax to retrieve a [version 2 secret](https://developer.hashicorp.com/vault/docs/secrets/kv/kv-v2), for example:

```yaml
publish_task:
  environment:
    AUTH_TOKEN: VAULT[secret/data/github data.token]
  script: ./publish.sh
```

The path is exactly the one you are familiar from invoking Vault CLI like [`vault read ...`](https://developer.hashicorp.com/vault/docs/commands/read), and the selector is a simply dot-delimited list of fields to query in the output.

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

=== "amd64"

    ```yaml
    test_task:
      container:
        matrix:
          - image: node:latest
          - image: node:lts
      test_script: yarn run test
    ```

=== "arm64"

    ```yaml
    test_task:
      arm_container:
        matrix:
          - image: node:latest
          - image: node:lts
      test_script: yarn run test
    ```

Which will be expanded into:

=== "amd64"

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

=== "arm64"

    ```yaml
    test_task:
      arm_container:
        image: node:latest
      test_script: yarn run test
    
    test_task:
      arm_container:
        image: node:lts
      test_script: yarn run test
    ```

!!! tip
    The `matrix` modifier can be used multiple times within a task.

The `matrix` modification makes it easy to create some pretty complex testing scenarios like this:

=== "amd64"

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

=== "arm64"

    ```yaml
    task:
      arm_container:
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

=== "amd64"

    ```yaml
    container:
      image: node:latest

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

=== "arm64"

    ```yaml
    arm_container:
      image: node:latest

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
    Just include `[skip ci]` or `[skip cirrus]` in the first line or last line of your commit message in order to skip CI execution for a commit completely.

    If you push multiple commits at the same time, only the last commit message will be checked for `[skip ci]` or `[ci skip]`.

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
    
    Note that `=~` operator can match against multiline values (dotall mode) and therefore looking for the exact occurrence of the regular expression
    so don't forget to use `.*` around your term for matching it at any position (for example, `$CIRRUS_CHANGE_TITLE =~ '.*[docs].*'`).

### Supported Functions

Currently two functions are supported in the `only_if` and `skip` expressions:

* `changesInclude` function allows to check which files were changed
* `changesIncludeOnly` is a more strict version of `changesInclude`, i.e. it won't evaluate to `true` if there are changed files other than the ones covered by patterns

These two functions behave differently for PR builds and regular builds:

* For PR builds, functions check the list of files affected by the PR.
* For regular builds, the `CIRRUS_LAST_GREEN_CHANGE` [environment variable](#environment-variables)
  will be used to determine list of affected files between `CIRRUS_LAST_GREEN_CHANGE` and `CIRRUS_CHANGE_IN_REPO`.
  In case `CIRRUS_LAST_GREEN_CHANGE` is not available (either it's a new branch or there were no passing builds before),
  list of files affected by a commit associated with `CIRRUS_CHANGE_IN_REPO` environment variable will be used instead.

`changesInclude` function can be very useful for skipping some tasks when no changes to sources have been made since the
last successful Cirrus CI build.

```yaml
lint_task:
  skip: "!changesInclude('.cirrus.yml', '**.{js,ts}')"
  script: yarn run lint
```

`changesIncludeOnly` function can be used to skip running a heavyweight task if only documentation was changed, for example:

```yaml
build_task:
  skip: "changesIncludeOnly('doc/*')"
```

## Auto-Cancellation of Tasks

Cirrus CI can automatically cancel tasks in case of new pushes to the same branch. By default, Cirrus CI auto-cancels
all tasks for non default branch (for most repositories `master` branch) but this behavior can be changed by specifying
`auto_cancellation` field:

```yaml
task:
  auto_cancellation: $CIRRUS_BRANCH != 'master' && $CIRRUS_BRANCH !=~ 'release/.*'
  ...
```

## Stateful Tasks

It's possible to tell Cirrus CI that a certain task is stateful and Cirrus CI will use a slightly different scheduling algorithm
to minimize chances of such tasks being interrupted. Stateful tasks are intended to use low CPU count.
**Scheduling times of such stateful tasks might be a bit longer then usual especially for tasks with high CPU requirements.**

By default, Cirrus CI marks a task as stateful if its name contains one of the following terms: `deploy`, `push`, `publish`, 
`upload` or `release`. Otherwise, you can explicitly mark a task as stateful via `stateful` field:

```yaml
task:
  name: Propagate to Production
  stateful: true
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

By default a Cirrus CI task is automatically triggered when all its [dependency tasks](#task-execution-dependencies)
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
supports `GET`, `POST`, `HEAD` and `DELETE` requests to upload, download, check presence and delete artifacts.

!!! info
    If port `12321` is available `CIRRUS_HTTP_CACHE_HOST` will be equal to `localhost:12321`.

For example running the following command:

```bash
curl -s -X POST --data-binary @myfolder.tar.gz http://$CIRRUS_HTTP_CACHE_HOST/name-key
```

...has the same effect as the following [caching instruction](#cache-instruction):

```yaml
name_cache:
  folder: myfolder
  fingerprint_key: key
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
should have a unique `name` and specify at least a container `image`.

Normally, you would also specify a `port` (or `ports`, if there are many) to instruct the Cirrus CI to configure the networking between the containers and wait for the ports to be available before running the task.
Additional containers do not inherit environment variables because they are started before the main task receives it's environment variables.

In the example below we use an [official MySQL Docker image](https://hub.docker.com/_/mysql/) that exposes
the standard MySQL port (3306). Tests will be able to access MySQL instance via `localhost:3306`.

=== "amd64"

    ```yaml
    container:
      image: golang:latest
      additional_containers:
        - name: mysql
          image: mysql:latest
          port: 3306
          cpu: 1.0
          memory: 512Mi
          env:
            MYSQL_ROOT_PASSWORD: ""
            MYSQL_ALLOW_EMPTY_PASSWORD: "yes"
    ```

=== "arm64"

    ```yaml
    arm_container:
      image: golang:latest
      additional_containers:
        - name: mysql
          image: mysql:latest
          port: 3306
          cpu: 1.0
          memory: 512Mi
          env:
            MYSQL_ROOT_PASSWORD: ""
            MYSQL_ALLOW_EMPTY_PASSWORD: "yes"
    ```

Additional container can be very handy in many scenarios. Please check [Cirrus CI catalog of examples](../examples.md) for more details.

??? info "Default Resources"
    By default, each additional container will get `0.5` CPU and `512Mi` of memory. These values can be configured as usual
    via `cpu` and `memory` fields.
    
??? tip "Port Mapping"
    It's also possible to map ports of additional containers by using `<HOST_PORT>:<CONTAINER_PORT>` format for the `port` field.
    For example, `port: 80:8080` will map port `8080` of the container to be available on local port `80` within a task.
  
    **Note:** don't use port mapping unless absolutely necessary. A perfect use case is when you have several additional containers
    which start the service on the same port and there's no easy way to change that. Port mapping limits 
    the number of places the container can be scheduled and will affect how fast such tasks are scheduled.
    
    To specify multiple mappings use the `ports` field, instead of the `port`:
    ```yaml
    ports:
      - 8080
      - 3306
    ```

??? tip "Overriding Default Command"
    It's also possible to override the default `CMD` of an additional container via `command` field:

    === "amd64"

        ```yaml
        container:
          image: golang:latest
          additional_containers:
            - name: mysql
              image: mysql:latest
              port: 7777
              command: mysqld --port 7777
              env:
                MYSQL_ROOT_PASSWORD: ""
                MYSQL_ALLOW_EMPTY_PASSWORD: "yes"
        ```

    === "arm64"

        ```yaml
        arm_container:
          image: golang:latest
          additional_containers:
            - name: mysql
              image: mysql:latest
              port: 7777
              command: mysqld --port 7777
              env:
                MYSQL_ROOT_PASSWORD: ""
                MYSQL_ALLOW_EMPTY_PASSWORD: "yes"
        ```

??? warning
    **Note** that `additional_containers` can be used only with the [Linux Clusters](linux.md),
    a [GKE](supported-computing-services.md#kubernetes-engine) cluster or a [EKS](supported-computing-services.md#eks) cluster.

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

Cirrus CI supports exporting information about the latest repository builds via the [CCTray XML format](https://cctray.org/), using the following URL format:

```console
https://api.cirrus-ci.com/github/<USER OR ORGANIZATION>/<REPOSITORY>/cctray.xml
```

Some tools with support of CCtray are:

* [CCMenu](http://ccmenu.org/) (macOS Native build status monitor).
* [Barklarm](https://www.barklarm.com/) (Open Source multiplatform alarm and build status monitor).
* [Nevergreen](https://github.com/build-canaries/nevergreen) (Build radiation service).

**Note:** for private repositories you'll need to configure [access token](../api.md#authorization).
