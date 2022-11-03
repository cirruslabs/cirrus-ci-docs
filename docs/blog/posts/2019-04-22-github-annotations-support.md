---
draft: false
date: 2019-04-22
authors:
  - fkorotkov
categories:
  - announcement
  - github
---

# GitHub Annotations Support

While working on a new functionality or fixing an issue it’s crucial to get CI feedback as soon as possible. Fast CI builds are important but it’s also important how fast one can find a reason of a failing build. Usual flow requires to open a separate page for the failing CI build and scroll through all the logs to finally find a relevant error message. How inefficient!

Today Cirrus CI starts supporting GitHub Annotations to provide inline feedback right where you review your code. No need to switch context anymore!

![](/blog/images/junit-annotations.png)

<!-- more -->

This became possible as a result of recently added features like [execution behaviour](https://cirrus-ci.org/guide/writing-tasks/#execution-behavior-of-instructions) and [artifacts](https://cirrus-ci.org/guide/writing-tasks/#artifacts-instruction). Now each artifact can specify a *format* so it can be parsed into annotations. Here is an example of `.cirrus.yml` file which saves and annotates JUnit reports of a Gradle build:

```yaml
container:  
  image: gradle:jdk8 

check_task:  
  script: gradle check  
  always:    
    junit_artifacts:      
      path: "**/test-results/**/*.xml"      
      format: junit
```

![](/blog/images/junit-annotations-task.png)

Currently Cirrus CI can only parse JUnit XML but many tools use this format already. Please [let us know](https://github.com/cirruslabs/cirrus-ci-annotations/issues/new) what kind of formats Cirrus CI should support next! [The annotation parser is also open source](https://github.com/cirruslabs/cirrus-ci-annotations) and contributions are highly appreciated! 😉

We highly encourage everyone to try Cirrus CI. It’s free for public repositories and all organizations get **200 CPU hours worth of [compute credits](https://cirrus-ci.org/pricing/)** to try it on private repositories.

As always don’t hesitate to ping [support](https://cirrus-ci.org/support/) or ask any questions [on Twitter](https://twitter.com/cirrus_labs).
