# Supported Computing Services

<p align="center">
  <a href="#google-cloud">
    <img style="width:128px;height:128px;" src="/assets/images/gcp/Google Cloud Platform.svg"/>
  </a>
  <a href="#compute-engine">
    <img style="width:128px;height:128px;" src="/assets/images/gcp/Compute Engine.svg"/>
  </a>
  <a href="#kubernetes-engine">
    <img style="width:128px;height:128px;" src="/assets/images/gcp/Container Engine.svg"/>
  </a>
  <a href="#kubernetes-engine">
    <img style="width:128px;height:128px;" src="/assets/images/gcp/Kubernetes_logo.svg" />
  </a>
</p>

<p align="center">
  <a href="#azure">
    <img style="width:128px;height:128px;" src="/assets/images/azure/Microsoft Azure.svg"/>
  </a>
  <a href="#azure-container-instances">
    <img style="width:128px;height:128px;" src="/assets/images/azure/Azure Container Service.svg"/>
  </a>
</p>

For every [task](writing-tasks.md) Cirrus CI starts a new Virtual Machine or a new Docker Container on a given compute service.
Using a new VM or a new Docker Container each time for running tasks has many benefits:

  * **Atomic changes to an environment where tasks are executed.** Everything about a task is configured in `.cirrus.yml` file including
    VM image version and Docker Container image version. After commiting changes to `.cirrus.yml` not only new tasks will use the new environment
    but also outdated branches will continue using the old configuration.
  * **Reproducibility.** Fresh environment guarantees no corrupted artifacts or caches are presented from the previous tasks.
  * **Cost efficiency.** Most compute services are offering per-second pricing which makes them ideal for using with Cirrus CI. 
    Also each task for repository can define ideal amount of CPUs and Memory specific for a nature of the task. No need to manage
    pools of similar VMs or try to fit workloads within limits of a given Continuous Integration systems.

To be fair there are of course some disadvantages of starting a new VM or a container for every task:

  * **Virtual Machine Startup Speed.** Starting a VM can take from a few dozen seconds to a minute or two depending on a cloud provider and
    a particular VM image. Starting a container on the other hand just takes a few hundred milliseconds! But even a minute
    on average for starting up VMs is not a big inconvenience in favor of more stable, reliable and more reproducible CI.
  * **Cold local caches for every task execution.** Many tools tend to store some caches like downloaded dependencies locally
    to avoid downloading them again in future. Since Cirrus CI always uses fresh VMs and containers such local caches will always
    be empty. Performance implication of empty local caches can be avoided by using Cirrus CI features like 
    [built-in caching mechanism](writing-tasks.md#cache-instruction). Some tools like [Gradle](https://gradle.org/) can 
    even take advantages of [built-in HTTP cache](writing-tasks.md#http-cache)!

Please check the list of currently supported cloud compute services below and please see what's [coming next](#coming-soon).

## Community Cluster

Community Cluster is a [Kubernetes](https://kubernetes.io/) cluster running on [Google Kubernetes Engine](#google-kubernetes-engine)
that is available free of charge for Open Source community. Paying customers can also use Community Cluster for personal private repositories.

Community Cluster is configured the same way as anyone can configure a personal GKE cluster as [described below](#google-kubernetes-engine).

By default a container is given 2 CPUs and 4 Gb of memory but it can be configured in `.cirrus.yml`:

```yaml
container:
  image: openjdk:8-jdk
  cpu: 4
  memory: 12
``` 

Containers on Community Cluster can use maximum 8.0 CPUs and up to 24 Gb of memory. [Custom GKE clusters](#google-kubernetes-engine) don't have that limitation though.

!!! warning "Scheduling Times on Community Cluster"
    Since Community Cluster is shared, scheduling times for containers can vary from time to time. Also the smaller a container 
    require resources faster it will be scheduled.

## Azure

<p align="center">
  <a href="#google-cloud">
    <img style="width:128px;height:128px;" src="/assets/images/azure/Microsoft Azure.svg"/>
  </a>
  </a>
</p>

Cirrus CI can schedule tasks on several Azure services. In order to interact with Azure APIs 
Cirrus CI needs permissions. First, please choose a subscription you want to use for scheduling CI tasks.
[Navigate to the Subscriptions blade within the Azure Portal](https://portal.azure.com/#blade/Microsoft_Azure_Billing/SubscriptionsBlade)
and save `$SUBSCRIPTION_ID` that we'll use below for setting up a service principle.

Creating a [service principal](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli) 
is a common way to safely give granular access to parts of Azure:

```bash
az ad sp create-for-rbac --name CirrusCI --sdk-auth \
  --scopes "/subscriptions/$SUBSCRIPTION_ID"
```

Command above will create a new service principal and will print something like:

```json
{
  "appId": "...",
  "displayName": "CirrusCI",
  "name": "http://CirrusCI",
  "password": "...",
  "tenant": "..."
}
``` 

Please create an [encrypted variable](writing-tasks.md#encrypted-variables) from this output and 
add it to the top of `.cirrus.yml` file:

```yaml
azure_credentials: ENCRYPTED[qwerty239abc]
```

Now Cirrus CI can interact with Azure APIs.

### Azure Container Instances

<p align="center">
  <a href="#compute-engine">
    <img style="width:128px;height:128px;" src="/assets/images/azure/Azure Container Service.svg"/>
  </a>
</p>

[Azure Container Instances (ACI)](https://azure.microsoft.com/en-us/services/container-instances/) allows is an ideal 
candidate for running modern CI workloads. ACI allows *just* to run Linux and Windows containers without thinking about 
underlying infrastructure.

Once `azure_credentials` is configured as described above, tasks can be scheduled on ACI by configuring `aci_instance` like this:


```yaml
azure_container_instance:
  image: cirrusci/windowsservercore:2016
  resource_group: CirrusCI
  region: westus
  platform: windows
  cpu: 4
  memory: 12G
```

!!! info "About Docker Images to use with ACI"
    Linux-based images are usually pretty small and doesn't require much tweaking. For Windows containers ACI recommends
    to follow a [few simple advices](https://docs.microsoft.com/en-us/azure/container-instances/container-instances-troubleshooting#container-takes-a-long-time-to-start)
    in order to reduce startup time.

## Google Cloud

<p align="center">
  <a href="#google-cloud">
    <img style="width:128px;height:128px;" src="/assets/images/gcp/Google Cloud Platform.svg"/>
  </a>
  </a>
</p>

Cirrus CI can schedule tasks on several Google Cloud Compute services. In order to interact with Google Cloud APIs 
Cirrus CI needs permissions. Creating a [service account](https://cloud.google.com/compute/access/service-accounts) 
is a common way to safely give granular access to parts of Google Cloud Projects. 

!!! warning "Isolation"
    We do recommend to create a separate Google Cloud project for running CI builds to make sure tests are
    isolated from production data. Having a separate project also will show how much money is spent on CI and how
    efficient Cirrus CI is :wink:

Once you have a Google Cloud project for Cirrus CI please create a service account by running the following command: 

```bash
gcloud iam service-accounts create cirrus-ci \
    --project $PROJECT_ID 
```

Depending on a compute service Cirrus CI will need different [roles](https://cloud.google.com/iam/understanding-roles) 
assigned to the service account. But Cirrus CI will always need permissions to Google Cloud Storage to store logs and caches. 
In order to give Google Cloud Storage permissions to the service account please run:

```bash
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:cirrus-ci@$PROJECT_ID.iam.gserviceaccount.com \
    --role roles/storage.admin
```

!!! info "Default Logs Retentions Period"
    By default Cirrus CI will store logs and caches for 30 days but it can be changed by manually configuring a
    [lifecycle rule](https://cloud.google.com/storage/lifecycle) for a Google Cloud Storage bucket that Cirrus CI is using.

Now we have a service account that Cirrus CI can use! It's time to let Cirrus CI know about that fact by securely providing a
private key for the service account. A private key can be created by running the following command:

```bash
gcloud iam service-accounts keys create service-account-credentials.json \
  --iam-account cirrus-ci@$PROJECT_ID.iam.gserviceaccount.com
```

At last create an [encrypted variable](writing-tasks.md#encrypted-variables) from contents of
`service-account-credentials.json` file and add it to the top of `.cirrus.yml` file:

```yaml
gcp_credentials: ENCRYPTED[qwerty239abc]
```

Now Cirrus CI can store logs and caches for scheduled tasks in Google Cloud Storage. Please check following sections 
with additional instructions about [Compute Engine](#compute-engine) or [Kubernetes Engine](#kubernetes-engine).

### Compute Engine

<p align="center">
  <a href="#compute-engine">
    <img style="width:128px;height:128px;" src="/assets/images/gcp/Compute Engine.svg"/>
  </a>
</p>

In order to schedule tasks on Google Compute Engine a service account that Cirrus CI operates via should have a necessary
role assigned. It can be done by running a `gcloud` command:

```bash
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:cirrus-ci@$PROJECT_ID.iam.gserviceaccount.com \
    --role roles/compute.admin
```

Now tasks can be scheduled on Compute Engine within `$PROJECT_ID` project by configuring `gce_instance` something 
like this:

```yaml
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

#### Custom VM images

Building an immutable VM image with all necessary software pre-configured is a known best practice with many benefits.
It makes sure environment where a task is executed is always the same and that no time is spent on useless work like
installing a package over and over again for every single task.

There are many ways how one can create a custom image for Google Compute Engine. Please refer to the [official documentation](https://cloud.google.com/compute/images/create-delete-deprecate-private-images).
At Cirrus Labs we are using [Packer](https://www.packer.io/builders/googlecompute.html) to automate building such
images. An example of how we use it can be found in [our public GitHub repository](https://github.com/cirruslabs/cirrus-images).

#### Windows Support

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

#### Instance Scopes

By default Cirrus CI will create Google Compute instances without any [scopes](https://cloud.google.com/sdk/gcloud/reference/alpha/compute/instances/set-scopes) 
so an instance can't access Google Cloud Storage for example. But sometimes it can be useful to give some permissions to an 
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

#### Preemptible Instances

Cirrus CI can schedule [preemptible](https://cloud.google.com/compute/instances/preemptible) instances with all price
benefits and stability risks. But sometimes risks of an instance being preempted at any time can be tolerated. For example 
`gce_instance` can be configured to schedule preemptible instance for non master branches like this:

```yaml
gce_instance:
  image_project: my-project
  image_name: my-custom-image-with-docker
  zone: us-central1-a
  preemptible: $CIRRUS_BRANCH != "master"
```

### Kubernetes Engine

<p align="center">
  <a href="#kubernetes-engine">
    <img style="width:128px;height:128px;" src="/assets/images/gcp/Container Engine.svg"/>
  </a>
</p>

Scheduling tasks on [Compute Engine](#google-compute-engine) has one big disadvantage of waiting for an instance to
start which usually takes around a minute. One minute is not that long but can't compete with hundreds of milliseconds
that takes a container cluster on GKE to start a container.

To start scheduling tasks on a container cluster we first need to create one using `gcloud`. Here is a command to create
an auto-scalable cluster that will scale down to zero nodes when there is no load for some time and quickly scale up with
the load during pick hours:

```yaml
gcloud container clusters create cirrus-ci-cluster \
  --project cirruslabs-ci \
  --zone us-central1-a \
  --num-nodes 1 --machine-type n1-standard-8 \
  --enable-autoscaling --min-nodes=0 --max-nodes=10
```

A service account that Cirrus CI operates via should be assigned with `container.admin` role that allows to administrate GKE clusters:

```bash
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:cirrus-ci@$PROJECT_ID.iam.gserviceaccount.com \
    --role roles/container.admin
```

Done! Now after creating `cirrus-ci-cluster` cluster and having `gcp_credentials` configured tasks can be scheduled on the 
newly created cluster like this:

```yaml
gcp_credentials: ENCRYPTED[qwerty239abc]

gke_container:
  image: gradle:4.3.0-jdk8
  cluster_name: cirrus-ci-cluster
  zone: us-central1-a
  namespace: default
  cpu: 6
  memory: 24Gb
```

## Coming Soon

We are actively working on supporting AWS.
