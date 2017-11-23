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
```

# Script Instruction

# Cache Instruction

# Encrypted Variable

# Matrix Modification

# HTTP Cache


