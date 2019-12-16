# Why Cirrus CI

* "Why yet another CI? There are gazillions of them already!"
* "We have X already configured. It's working for us. Why should we switch?"

These are all valid concerns. Here at [Cirrus Labs](http://cirruslabs.org/), we tried them all before we decided to build a new CI. 
We wouldn't have built it if we didn't think it was necessary and there was no need for a better CI.

There are continuous integration systems that have been in development for 10+ years. They are super flexible and 
can be configured for almost any workflow. But this flexibility and long history bring some fundamental problems:

* It's so easy to mess up.
* Which plugins to install and which to uninstall?
* How to configure builds?
* How to configure auto-scalable agent pools? 
* How to update agent pools...
    * so as to not affect builds in flight?
    * so old release branches can still be executed?

Basically there should be someone very knowledgeable to properly configure and **maintain** CI.

There are also some modern CI-as-a-service systems founded in the last 6 years which are not so flexible, 
but they are doing great job of making continuous integration as simple as possible. Those also have some common
inconveniences like:

* Not pay-as-you-go approach for pricing. Usually users pay for how many containers at a time one can execute. 
  Which means if users don't want to face queuing issues they need to plan and pay for the maximum load they'll have. 
  This is not a suitable pricing model for the era of cloud computing.
* Focused mostly on containers which many businesses have not yet migrated their legacy projects to.
* Poor environment flexibility. It's not possible to specify precisely which VM image or Docker container to run and
  how much resources it can have.

Because of all the problems and inconveniences described above, we decided to build Cirrus CI with three simple principles in mind:

1. Simple in details.
2. Efficient everywhere.
3. Transparent and honest with users. 
