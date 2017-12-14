# Frequently Asked Questions

#### Is Cirrus CI a delivery platform?

Cirrus CI is not positioned as a delivery platform but can be used as one for many general use cases by having 
[Dependencies](docs/writing-tasks.md#dependencies) between tasks and using [Conditional Task Execution](docs/writing-tasks.md#conditional-task-execution):

```yaml
lint_task:
  script: yarn run lint

test_task:
  script: yarn run test

publish_task:
  only_if: $BRANCH == 'master'
  depends_on: 
    - test
    - lint
  script: yarn run publish
```

#### Mac OS X Support?

**TLDR**: not in the near future.

We are planning to spend Q1 and Q2 of 2018 on [GA](https://en.wikipedia.org/wiki/Software_release_life_cycle#General_availability_(GA)) 
of Cirrus CI and on support for AWS and Azure. We are going to revisit Mac OS support in Q3 2018. Cirrus CI has everything 
for running Mac OS builds except a [computing service](docs/supported-computing-services.md) that can effectively 
schedule Mac OS VMs. Please [let us know](support.md) if there is such a service and we can try to work together to bring
Mac OS support earlier :wink:.
