## Introduction into Starlark

Most commonly, Cirrus tasks are declared in `.cirrus.yml` file in YAML format as documented in [*Writing Tasks*](writing-tasks.md) guide.

YAML, as a language, is great for declaring simple to moderate configurations, but sometimes just using a declarative language is not enough.
One might need some conditional execution or have an easy way to generate multiple similar tasks. Most of the CIs solve this problem
by introducing special DSL into the existing YAML. In case of Cirrus CI, we have [`only_if` keyword](writing-tasks.md#conditional-task-execution)
for conditional execution and [`matrix` modification](writing-tasks.md#matrix-modification) for generating similar tasks.
These options are mostly hacks to workaround declarative nature of YAML language where in reality an imperative language
looks like a better fit. This is why Cirrus CI allows in additional to YAML configure tasks via Starlark.

Starlark language is a procedural programming language [originated from Bazel build tool](https://docs.bazel.build/versions/master/skylark/language.html),
but ideal for embedding within any other system that want to safely allow user-defined logic. There are a few key differences which made us
choose Starlark instead of common alternatives like JavaScript/TypeScript or WebAssembly:

1. Starlark doesn't require compilation. No need to introduce full-blown compile and deploy process for a few dozen lines of logic.
2. Starlark script can be executed instantly on any platform. There is Starlark interpreter written in Go which integrates nicely with Cirrus CLI and Cirrus CI infrastructure.
3. Starlark has built-in functionality for loading external modules which is ideal for config sharing. See [module loading](#module-loading) for details.

## Writing Starlark scripts

Let's start with a trivial `.cirrus.star` example like this:

```python
def main():
    return [
        {
            "container": {
                "image": "debian:latest",
            },
            "script": "make",
        },
    ]
```

With the [module loading](#module-loading), you can re-use other people's code to avoid wasting time on things written from scratch.
For example, with the official [task helpers](https://github.com/cirrus-modules/helpers) the example above can be refactored in:

```python
load("github.com/cirrus-modules/helpers", "task", "container", "script")

def main(ctx):
  return [
    task(
      instance=container("debian:latest"),
      instructions=[script("make")]
    ),
  ]
```

`main()` needs to return a list of task objects which will be serialized into YAML, like this:

```yaml
task:
    container:
      image: debian:latest
    script: make
```

Then the generated YAML is appended to `.cirrus.yml` (if any) before passing the combined config into the final YAML parser.

With Starlark, it's possible to generate parts of the configuration dynamically based on some external conditions:

* [Parsing files inside the repository](#fs) to pick up some common settings (for example, parse `package.json` to see if it contains `lint` script and generate a linting task).
* [Making an HTTP request](#http) to check the previous build status.

See a video tutorial on how to create a custom Cirrus module:

<iframe width="560" height="315" src="https://www.youtube.com/embed/fPEe-xocfxQ" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

### Entrypoints

Different events will trigger execution of different top-level functions in the `.cirrus.star`. These functions reserve certain names
and will be called with different arguments depending on the event which triggered the execution.

#### `main()`

`main()` is called once a Cirrus CI build is triggered in order to generate a list of tasks to execute within that particular build:

```python
def main():
    return [
      {
        "container": {
          "image": "debian:latest"
        },
        "script": "make test"
      },
      {
        "container": {
          "image": "debian:latest"
        },
        "script": "make build"
      }
    ]
```

You can also return a dictionary that fully resembles a YAML configuration, just make sure to give the tasks different names, because Starlark does not permit duplicate dictionary keys:

```python
def main():
    return {
        "container": {
          "image": "debian:latest",
        },
        "test_task": {
          "script": "make test"
        },
        "build_task": {
          "script": "make build"
        }
    }
```

Returning a dictionary like this is useful when you want to have a top-level overrides, just note that when using both YAML and Starlark configuration formats they get merged and the YAML configuration always comes first.

#### Hooks

It's also possible to execute Starlark scripts on updates to the current build or any of the tasks within the build.
Think of it as [WebHooks](../api.md#webhooks) running within Cirrus that doesn't require any infrastructure on your end.

Expected names of Starlark Hook functions in `.cirrus.star` are `on_build_<STATUS>` or `on_task_<STATUS>` respectively.
Please refer to [Cirrus CI GraphQL Schema](https://github.com/cirruslabs/cirrus-ci-web/blob/master/schema.graphql) for a
full list of existing statuses, but most commonly  `on_build_failed`/`on_build_completed` and `on_task_failed`/`on_task_completed`
are used. These functions should expect a single context argument passed by Cirrus Cloud. At the moment hook's context only contains
a single field `payload` containing the [same payload as a webhook](../api.md#webhooks). 

One caveat of Starlark Hooks execution is `CIRRUS_TOKEN` [environment variable](#env) that contains a token to access [Cirrus API](../api.md).
Scope of `CIRRUS_TOKEN` is restricted to the build associated with that particular hook invocation and allows, for example,
to automatically re-run tasks. Here is an example of a Starlark Hook that automatically re-runs a failed task in case a particular
transient issue found in logs:

```python
# load some helpers from an external module 
load("github.com/cirrus-modules/graphql", "rerun_task_if_issue_in_logs")

def on_task_failed(ctx):
  if "Test" not in ctx.payload.data.task.name:
    return
  if ctx.payload.data.task.automaticReRun:
    print("Task is already an automatic re-run! Won't even try to re-run it...")
    return
  rerun_task_if_issue_in_logs(ctx.payload.data.task.id, "Time out")
```

### Module loading

Module loading is done through the Starlark's [`load()`](https://github.com/bazelbuild/starlark/blob/master/spec.md#load-statements) statement.

Besides the ability to load [builtins](#builtins) with it, Cirrus can load other `.star` files from local and remote locations to facilitate code re-use.

#### Local

Local loads are relative to the project's root (where `.cirrus.star` is located):

```python
load(".ci/notify-slack.star", "notify_slack")
```

#### Remote from Git

To load the default branch of the module from GitHub:

```python
load("github.com/cirrus-modules/golang", "task", "container")
```

In the example above, the name of the `.star` file was not provided, because `lib.star` is assumed by default. This is equivalent to:

```python
load("github.com/cirrus-modules/golang/lib.star@main", "task", "container")
```

You can also specify an exact commit hash instead of the `main()` branch name to prevent accidental changes.

To load `.star` files from repositories other than GitHub, add a `.git` suffix at the end of the repository name, for example:

```python
load("gitlab.com/fictional/repository.git/validator.star", "validate")
                                     ^^^^ note the suffix
```

## Builtins

Cirrus CLI provides builtins all nested in the `cirrus` module that greatly extend what can be done with the Starlark alone.

### `fs`

These builtins allow for read-only filesystem access.

All paths are relative to the project's directory.

#### `fs.exists(path)`

Returns `True` if `path` exists and `False` otherwise.

#### `fs.read(path)`

Returns a [`string`](https://github.com/bazelbuild/starlark/blob/master/spec.md#strings) with the file contents or `None` if the file doesn't exist.

Note that this is an error to read a directory with `fs.read()`.

#### `fs.readdir(dirpath)`

Returns a [`list`](https://github.com/bazelbuild/starlark/blob/master/spec.md#lists) of [`string`'s](https://github.com/bazelbuild/starlark/blob/master/spec.md#strings) with names of the entries in the directory.

Note that this is an error to read a file with `fs.readdir()`.

Example:

```python
load("cirrus", "fs")

def main(ctx):
    tasks = base_tasks()

    if fs.exists("go.mod"):
        tasks += go_tasks()

    return tasks
```

### `is_test`

While not technically a builtin, `is_test` is a [`bool`](https://github.com/bazelbuild/starlark/blob/master/spec.md#booleans)
that allows Starlark code to determine whether it's running in test environment via Cirrus CLI. This can be useful for limiting the test complexity,
e.g. by not making a real HTTP request and mocking/skipping it instead. Read more about module testing in a [separate guide in Cirrus CLI repository](https://github.com/cirruslabs/cirrus-cli/blob/master/STARLARK-TEMPLATING.md#testing).

### `env`

While not technically a builtin, `env` is dict that contains [environment variables](writing-tasks.md#environment-variables).

Example:

```python
load("cirrus", "env")

def main(ctx):
    tasks = base_tasks()

    if env.get("CIRRUS_TAG") != None:
        tasks += release_tasks()

    return tasks
```

### `changes_include`

`changes_include()` is a Starlark alternative to the [changesInclude()](writing-tasks.md#supported-functions) function commonly found in the YAML configuration files.

It takes at least one [`string`](https://github.com/bazelbuild/starlark/blob/master/spec.md#strings) with a pattern and returns a [`bool`](https://github.com/bazelbuild/starlark/blob/master/spec.md#booleans) that represents whether any of the specified patterns matched any of the affected files in the running context.

Currently supported contexts:

* [`main()` entrypoint](#build-generation)

Example:

```python
load("cirrus", "changes_include")

def main(ctx):
    tasks = base_tasks()

    if changes_include("Dockerfile"):
        tasks += docker_task()

    return tasks
```

### `changes_include_only`

`changes_include_only()` is a Starlark alternative to the [changesIncludeOnly()](writing-tasks.md#supported-functions) function commonly found in the YAML configuration files.

It takes at least one [`string`](https://github.com/bazelbuild/starlark/blob/master/spec.md#strings) with a pattern and returns a [`bool`](https://github.com/bazelbuild/starlark/blob/master/spec.md#booleans) that represents whether any of the specified patterns matched all the affected files in the running context.

Currently supported contexts:

* [`main()` entrypoint](#build-generation)

Example:

```python
load("cirrus", "changes_include_only")

def main(ctx):
    if changes_include_only("doc/*"):
        return []

    return base_tasks()
```

### `http`

Provides HTTP client implementation with `http.get()`, `http.post()` and other HTTP method functions.

Refer to the [starlib's documentation](https://github.com/qri-io/starlib/tree/master/http) for more details.

### `hash`

Provides cryptographic hashing functions, such as `hash.md5()`, `hash.sha1()` and `hash.sha256()`.

Refer to the [starlib's documentation](https://github.com/qri-io/starlib/tree/master/hash) for more details.

### `base64`

Provides Base64 encoding and decoding functions using `base64.encode()` and `base64.decode()`.

Refer to the [starlib's documentation](https://github.com/qri-io/starlib/tree/master/encoding/base64) for more details.

### `json`

Provides JSON document marshalling and unmarshalling using `json.dumps()` and `json.loads()` functions.

Refer to the [starlib's documentation](https://github.com/qri-io/starlib/tree/master/encoding/json) for more details.

### `yaml`

Provides YAML document marshalling and unmarshalling using `yaml.dumps()` and `yaml.loads()` functions.

Refer to the [starlib's documentation](https://github.com/qri-io/starlib/tree/master/encoding/yaml) for more details.

### `re`

Provides regular expression functions, such as `findall()`, `split()` and `sub()`.

Refer to the [starlib's documentation](https://github.com/qri-io/starlib/tree/master/re) for more details.

### `zipfile`

`cirrus.zipfile` module provides methods to read Zip archives.

You instantiate a `ZipFile` object using `zipfile.ZipFile(data)` function call and then call `namelist()` and `open(filename)` methods to retrieve information about archive contents.

Refer to the [starlib's documentation](https://github.com/qri-io/starlib/tree/master/zipfile) for more details.

Example:

```python
load("cirrus", "fs", "zipfile")

def is_java_archive(path):
    # Read Zip archive contents from the filesystem
    archive_contents = fs.read(path)
    if archive_contents == None:
        return False

    # Open Zip archive and a file inside of it
    zf = zipfile.ZipFile(archive_contents)
    manifest = zf.open("META-INF/MANIFEST.MF")

    # Does the manifest contain the expected version?
    if "Manifest-Version: 1.0" in manifest.read():
        return True

    return False
```
