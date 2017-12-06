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
