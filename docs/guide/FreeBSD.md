## FreeBSD Virtual Machines

It is possible to run FreeBSD Virtual Machines the same way one can run [Linux containers](linux.md) on the FreeBSD Cloud Cluster.
To accomplish this, use `freebsd_instance` in your `.cirrus.yml`:

```yaml
freebsd_instance:
  image_family: freebsd-14-0

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
      image: family/freebsd-14-0
      platform: freebsd
    ```

## List of available image families

Any of the official FreeBSD VMs on Google Cloud Platform are supported. Here are a few of them which are self explanatory:

* `freebsd-15-0-snap` (15.0-SNAP)
* `freebsd-14-0`      (14.0-RELEASE)
* `freebsd-13-3`      (13.3-RELEASE)

It's also possible to specify a concrete version of an image by name via `image_name` field. To get a full list of
available images please run the following [gcloud](https://cloud.google.com/sdk/gcloud/) command:

```bash
gcloud compute images list --project freebsd-org-cloud-dev --no-standard-images
```
