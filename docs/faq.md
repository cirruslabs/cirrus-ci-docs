# Frequently Asked Questions

#### Is Cirrus CI a delivery platform?

Cirrus CI is not positioned as a delivery platform but can be used as one for many general use cases by having 
[Dependencies](guide/writing-tasks.md#dependencies) between tasks and using [Conditional Task Execution](guide/writing-tasks.md#conditional-task-execution):

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

We are planning to spend Q2 of 2018 on supporting for AWS and Azure. We are going to revisit Mac OS support in Q3 2018. Cirrus CI has everything 
for running Mac OS builds except a [computing service](guide/supported-computing-services.md) that can effectively 
schedule Mac OS VMs. Please [let us know](support.md) if there is such a service and we can try to work together to bring
Mac OS support earlier :wink:.

#### Only GitHub Support?

At the moment Cirrus CI only supports GitHub via a [GitHub Application](https://github.com/apps/cirrus-ci). We are planning
to [support BitBucket](https://github.com/cirruslabs/cirrus-ci-docs/issues/9) next. 

#### Any discounts?

Cirrus CI itself doesn't provide any discounts except [Community Cluster](/guide/supported-computing-services.md#community-cluster) 
which is free for open source projects. But since Cirrus CI delegates execution of builds to different computing services,
it means that discounts from your cloud provider will be applied to Cirrus CI builds.
