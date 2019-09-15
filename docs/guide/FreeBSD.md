## FreeBSD Virtual Machines

It is possible to run FreeBSD Virtual Machines the same way one can run [Linux containers](linux.md) on FreeBSD Community Cluster. 
Simply use `freebsd_instance` in `.cirrus.yml` files:

```yaml
freebsd_instance:
  image_family: freebsd-12-0

task:
  install_script: pkg install -y ...
  script: ...
```

!!! info "Under the Hood"
    Under the hood a simple integration with [Google Compute Engine](supported-computing-services.md#compute-engine) 
    is used.

## List of available image families

Any of the official FreeBSD VMs on Google Cloud Platform are supported. Here are a few of them which are self explanatory:

* `freebsd-13-0-snap`
* `freebsd-12-0`
* `freebsd-11-3`
* `freebsd-11-2`
* `freebsd-10-4`

It's also possible to specify a concrete version of an image by name via `image_name` field. To get a full list of
available images please run the following [gcloud](https://cloud.google.com/sdk/gcloud/) command:

```bash
gcloud compute images list --project freebsd-org-cloud-dev --no-standard-images
```
