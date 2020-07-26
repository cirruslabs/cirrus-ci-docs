## FreeBSD Virtual Machines

It is possible to run FreeBSD Virtual Machines the same way one can run [Linux containers](linux.md) on FreeBSD Community Cluster. 
Simply use `freebsd_instance` in `.cirrus.yml` files:

```yaml
freebsd_instance:
  image_family: freebsd-12-1

task:
  install_script: pkg install -y ...
  script: ...
```

!!! info "Under the Hood"
    Under the hood a simple integration with [Google Compute Engine](supported-computing-services.md#compute-engine) 
    is used.

## List of available image families

Any of the official FreeBSD VMs on Google Cloud Platform are supported. Here are a few of them which are self explanatory:

* `freebsd-13-0-snap` (13.0-CURRENT)
* `freebsd-12-1-snap` (12.1-STABLE)
* `freebsd-12-1`      (12.1-RELEASE)
* `freebsd-12-0`      (12.0-RELEASE)
* `freebsd-11-4`      (11.4-RELEASE)
* `freebsd-11-3-snap` (11.3-STABLE)
* `freebsd-11-3`      (11.3-RELEASE, doesn't boot properly at the moment)

It's also possible to specify a concrete version of an image by name via `image_name` field. To get a full list of
available images please run the following [gcloud](https://cloud.google.com/sdk/gcloud/) command:

```bash
gcloud compute images list --project freebsd-org-cloud-dev --no-standard-images
```
