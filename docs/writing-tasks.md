# Writing Tasks

Task defines where and how your scripts will be executed. Let's check line-by-line an example of `.cirrus.yml` configuration file first:

```yaml
task:
  container:
    image: gradle:4.3.0-jdk8
    cpu: 8
    memory: 20G
  script: gradle test
```

Example above defines a single task that will be scheduled and executed on Community Cluster using `gradle:4.3.0-jdk8` Docker image.
Only one user defined script instruction to run `gradle test` will be executed. Pretty simple, isn't it?

A `task` simply defines a [compute service](deoc/supported-computing-services.md) to schedule the task on and 
a sequence of [`script`](#script-instruction) and [`cache`](#cache-instruction) instructions that will be executed.

Please read topics below if you want better understand what's doing on in a more complex `.cirrus.yml` configuration file like this:

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

# Script Instruction

`script` instruction executes commands via `shell` on Unix or `batch` on Windows. `script` instruction can be named by
adding a name as a prefix. For example `test_script` or `my_very_specific_build_step_script`. Naming script instructions
helps gather more granular information about task execution. Cirrus CI will use it in future to auto-detect performance 
regressions.

Script commands can be specified as a single string value or a list of string values in `.cirrus.yml` configuration file
like in an example below:

```yaml
check_task:
  compile_script: gradle --parallel classes testClasses 
  check_script:
    - printenv
    - gradle check
``` 

# Cache Instruction

`cache` instruction allows to save some folder in cache based on a fingerprint and reuse it during the next execution 
of the task with the same fingerprint. `cache` instruction can be named the same way as `script` instruction.

Here is an example: 

```yaml
test_task:
  node_modules_cache:
    folder: node_modules
    fingerprint_script: cat yarn.lock
    populate_script: yarn install
  test_script: yarn run test
```

`fingerprint_script` is an optional field that can specify a script that will be executed and console output of which
will be used as a fingerprint for the given task. By default task name is used as a fingerprint value.

`fingerprint_script` is an optional field that can specify a script that will be executed to populate the cache. 
`fingerprint_script` should create `folder`.

!> Note that cache folder will be archived and uploaded only in the very end of the task execution once all instructions succeed.

Which means the only difference between example above and below is that `yarn install` will always be executed in the 
example below where in the example above only when `yarn.lock` has changes.

```yaml
test_task:      
  node_modules_cache:
    folder: node_modules
    fingerprint_script: cat yarn.lock
  install_script: yarn install
  test_script: yarn run test
```

# Environment Variables

Environment variables can be configured under `environment` keyword in `.cirrus.yml` file. Here is an example:

```yaml
echo_task:
  environment:
    FOO: Bar
  echo_script: echo $FOO   
```

# Encrypted Variable

# Matrix Modification

Sometimes it's useful to run the same task against different software versions. Or run different batches of tests based
on an environment variable. For cases like these `matrix` modification comes very handy. It's possible to use `matrix`
keyword anywhere inside of a particular task to have multiple tasks based on the original one. Each new task will be created
from the original task by replacing the whole `matrix` YAML node with each `matrix`'s children separately. 

Let check an example of `.cirrus.yml`:

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

!> `matrix` modification can be used multiple times within a task.

`matrix` modification makes it easy to create some pretty complex testing scenarios like this:

```yaml
test_task:
  container:
    matrix:
      image: node:latest
      image: node:8.3.0
  environment:
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

# Dependencies

Sometimes it might be very handy execute some tasks only after successful execution of other tasks. For such cases
it's possible specify for a task names of other tasks it depends on with `depends_on` keyword:

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

# HTTP Cache


