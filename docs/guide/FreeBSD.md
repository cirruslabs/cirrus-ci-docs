## FreeBSD Virtual Machines

It is possible to run FreeBSD Virtual Machines the same way one can run [Linux containers](linux.md) on FreeBSD Community Cluster. 
Simply use `freebsd_instance` in `.cirrus.yml` files:

```yaml
freebsd_instance:
  image: freebsd-11-2-release-amd64

task:
  install_script: pkg install -y ...
  script: ...
```

!!! info "Under the Hood"
    Under the hood a simple integration with [Google Compute Engine](supported-computing-services.md#compute-engine) 
    is used.

## List of available images

Any of the official FreeBSD VMs on Google Cloud Platform are supported. Here are a few of them which are self explanatory:

* `freebsd-12-0-release-amd64`
* `freebsd-11-2-release-amd64`
* `freebsd-11-3-stable-amd64-v20190808`
* `freebsd-11-1-release-amd64`
* `freebsd-10-4-release-amd64`

To get a full list of available images please run the following [gcloud](https://cloud.google.com/sdk/gcloud/) command:

```bash
gcloud compute images list --project freebsd-org-cloud-dev --no-standard-images
```
