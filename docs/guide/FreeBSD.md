## FreeBSD Virtual Machines

It is possible to run FreeBSD Virtual Machines the same way one can run [Linux containers](linux.md) on the FreeBSD Cloud Cluster. 
To accomplish this, use `freebsd_instance` in your `.cirrus.yml`:

```yaml
freebsd_instance:
  image_family: freebsd-13-0

task:
  install_script: pkg install -y ...
  script: ...
```

!!! info "Under the Hood"
    Under the hood, a basic integration with [Google Compute Engine](supported-computing-services.md#compute-engine) 
    is used and `freebsd_instance` is a syntactic sugar for the following [`compute_engine_instance`](custom-vms.md) configuration:

    ```yaml
    compute_engine_instance:
      image_project: freebsd-org-cloud-dev
      image: family/freebsd-13-0
      platform: freebsd
    ```

## List of available image families

Any of the official FreeBSD VMs on Google Cloud Platform are supported. Here are a few of them which are self explanatory:

* `freebsd-14-0-snap` (14.0-SNAP)
* `freebsd-13-1`      (13.1-RELEASE)
* `freebsd-13-0`      (13.0-RELEASE)
* `freebsd-12-3`      (12.3-RELEASE)
* `freebsd-12-2`      (12.2-RELEASE)
* `freebsd-12-0`      (12.0-RELEASE)
* `freebsd-11-4`      (11.4-RELEASE)
* `freebsd-11-3-snap` (11.3-STABLE)
* `freebsd-11-3`      (11.3-RELEASE, doesn't boot properly at the moment)

It's also possible to specify a concrete version of an image by name via `image_name` field. To get a full list of
available images please run the following [gcloud](https://cloud.google.com/sdk/gcloud/) command:

```bash
gcloud compute images list --project freebsd-org-cloud-dev --no-standard-images
```
