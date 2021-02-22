## Custom Compute Engine VMs

Cirrus CI supports [many different compute services](supported-computing-services.md) when you bring your own infrastructure, 
but internally at Cirrus Labs we use Google Cloud Platform for running all [managed by us instances](writing-tasks.md#execution-environment)
except `macos_instance`. Already things like [Docker Builder](docker-builder-vm.md) and [`freebsd_instance`](FreeBSD.md)
are basically a syntactic sugar for launching Compute Engine instances from a particular limited set of images.

With `compute_engine_instance` it is possible to use any publicly available image for running your Cirrus tasks in.
Such instances are particularly useful when you can't use Docker containers, for example, when you need to test things
against newer versions of Linux kernel then the Docker host has.

```yaml
compute_engine_instance:
  image_project: cirrus-images
  image: family/docker-kvm # family or simply a full image name.
  platform: linux
  cpu: 4
  memory: 16G
  nested_virtualization: true # Whether to enable Intel VT-x. Defaults to false. 
```

# Building custom image for Compute Engine

We recommend to use [Packer](https://www.packer.io/) for building your custom images. As an example, please take a look at [our Packer templates](https://github.com/cirruslabs/osx-images)
used for building Docker Builder VM image.

After building your image, please make sure [the image publicly available](https://cloud.google.com/compute/docs/images/managing-access-custom-images#share-images-publicly):

```bash
gcloud compute images add-iam-policy-binding $IMAGE_NAME \
    --member='allAuthenticatedUsers' \
    --role='roles/compute.imageUser'
```
