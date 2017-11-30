# Supported Computing Services

For every [task](docs/writing-tasks.md) Cirrus CI start a new Virtual Machine or a new Docker Container on a given compute service.
Using a new VM or a new Docker Container each time for running tasks has many benefits:
* *Atomic changes to an environment where tasks are executed.* Everything about a task is configured in `.cirrus.yml` file including
VM image version and Docker Container image version. After commiting changes to `.cirrus.yml` not only new tasks will use the new environment
but also outdated branches will continue using the old configuration.
* *Reproducibility.* Fresh environment guarantees no corrupted artifacts or caches are presented from the previous tasks.
* *Cost efficiency.* Most compute services are offering per-second pricing which makes them ideal for using with Cirrus CI. 
Also each task for repository can define ideal amount of CPUs and Memory specific for a nature of the task. No need to manage
pools of similar VMs or try to fit workloads within limits of a given Continuous Integration systems.

To be fair there are of course some disadvantages of starting a new VM or a container for every task:
* *Virtual Machine Startup Speed.* Starting a VM can take from a few dozen seconds to a minute or two depending on a cloud provider and
a particular VM image. Starting a container on the other hand just takes a few hundred milliseconds! But even a minute
on average for starting up VMs is not a big inconvenience in favor of more stable, reliable and more reproducible CI.
* *Cold local caches for every task execution.* Many tools tend to store some caches like downloaded dependencies locally
to avoid downloading them again in future. Since Cirrus CI always uses fresh VMs and containers such local caches will always
be empty. Performance implication of empty local caches can be avoided by using Cirrus CI features like 
[built-in caching mechanism](docs/writing-tasks.md#cache-instruction). Some tools like [Gradle](https://gradle.org/) can 
even take advantages of [built-in HTTP cache](docs/writing-tasks.md#http-cache)!

Please check the list of currently supported cloud compute services below and please see what's [coming next](#coming-soon).

## Community Cluster

Community Cluster is simply a [Kubernetes](https://kubernetes.io/) cluster running on [Google Kubernetes Engine](#google-kubernetes-engine)
that is available free of change for Open Source community. Paying customers can also use Community Cluster for personal private repositories.

## Google Compute Engine

In order to interact with GCE APIs to create and delete instances for tasks Cirrus CI needs permissions. Creating a 
[service account](https://cloud.google.com/compute/docs/access/service-accounts) is a common way to safely give granular
access to parts of Google Cloud Projects. We do recommend though to create a separate Google Cloud project for running 
CI builds as a best practice.

Once you have a Google Cloud project to run Cirrus CI builds on simply create a service account by running following command: 

```bash
gcloud iam service-accounts create cirrus-ci \
    --project $PROJECT_ID 
```

Now we need to give an access to Compute Engine to the newly created service account:

```bash
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:cirrus-ci@$PROJECT_ID.iam.gserviceaccount.com \
    --role roles/compute.admin
```

We also need to give an access to Google Storage so Cirrus CI can store logs and caches in it:

```bash
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:cirrus-ci@$PROJECT_ID.iam.gserviceaccount.com \
    --role roles/storage.admin
```

?> By default Cirrus CI will store logs and caches for 30 days but it can be changed by manually changing a
[lifecycle rule](https://cloud.google.com/storage/docs/lifecycle) for a Google Storage bucket that Cirrus CI is using.

Now we have a service account that Cirrus CI can use! It's time to let Cirrus CI know about that fact by proving a
private key for the service account. A private key can be created by running the following command:

```bash
gcloud iam service-accounts keys create service-account-credentials.json \
  --iam-account cirrus-ci@$PROJECT_ID.iam.gserviceaccount.com
```

And the last step is to create an [encrypted variable](docs/writing-tasks.md#encrypted-variables) from contents of
`service-account-credentials.json` file and add it to `.cirrus.yml` file:

```yaml
gcp_credentials: ENCRYPTED[qwerty239abc]
```

Done! Now tasks can be scheduled on Compute Engine within `$PROJECT_ID` project by configuring `gce_instance` something 
like this:

```yaml
gcp_credentials: ENCRYPTED[qwerty239abc]

gce_instance:
  image_project: ubuntu-os-cloud
  image_name: ubuntu-1604-xenial-v20171121a
  zone: us-central1-a
  cpu: 8
  memory: 40Gb
  disk: 20
  
task:
  script: ./run-ci.sh
```

### Custom VM images

Building an immutable VM image with all necessary software pre-configured is a known best practice with many benefits.
It makes sure environment where a task is executed is always the same and that no time is spent on useless work like
installing a package over and over again for every single task.

There are many ways how one can create a custom image for Google Compute Engine. Please refer to the [official documentation](https://cloud.google.com/compute/docs/images/create-delete-deprecate-private-images).
At Cirrus Labs we are using [Packer](https://www.packer.io/docs/builders/googlecompute.html) to automate building such
images. An example of how we use it can be found in [our public GitHub repository](https://github.com/cirruslabs/cirrus-images).

### Windows Support

Google Compute Engine support Windows images and Cirrus CI can take full advantages of it by just explicitly specifying
platform of an image like this:

```yaml
gce_instance:
  image_project: windows-cloud
  image_name: windows-server-2016-dc-core-v20170913
  platform: windows
  zone: us-central1-a
  cpu: 8
  memory: 40Gb
  disk: 20
  
task:
  script: run-ci.bat
```

### Instance Scopes

By default Cirrus CI will create Google Compute instances without any [scopes](https://cloud.google.com/sdk/gcloud/reference/alpha/compute/instances/set-scopes) 
so an instance can't access Google Storage for example. But sometimes it can be useful to give some permissions to an 
instance by using `scopes` key of `gce_instance`.  For example if a particular task builds Docker images and then pushes 
them to [Container Registry](https://cloud.google.com/container-registry/) it's configuration file can look something like:

```yaml
gcp_credentials: ENCRYPTED[qwerty239abc]

gce_instance:
  image_project: my-project
  image_name: my-custom-image-with-docker
  zone: us-central1-a
  cpu: 8
  memory: 40Gb
  disk: 20

test_task:
  test_script: ./scripts/test.sh

push_docker_task:
  depends_on: test
  only_if: $CIRRUS_BRANCH == "master"
  gce_instance:
    scopes: cloud-platform
  push_script: ./scripts/push_docker.sh
```

### Preemptible Instances

Cirrus CI can schedule [preemptible](https://cloud.google.com/compute/docs/instances/preemptible) instances with all price
benefits and stability risks. But sometimes risks of an instance being preempted at any time can be tolerated. For example 
`gce_instance` can be configured to schedule preemptible instance for non master branches like this:

```yaml
gce_instance:
  image_project: my-project
  image_name: my-custom-image-with-docker
  zone: us-central1-a
  preemptible: $CIRRUS_BRANCH != "master"
```

## Google Kubernetes Engine

## Coming Soon

We are actively working on supporting AWS and Azure and planning to add support for them in the end of Q1 2018.
