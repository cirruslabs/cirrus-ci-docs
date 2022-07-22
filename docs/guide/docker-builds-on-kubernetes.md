## Docker Builds on Kubernetes

Besides the ability to build docker images using a dedicated `docker_builder` task which runs on VMs, it is also possible to run docker builds on Kubernetes.
To do so we are leveraging the `additional_containers` and `docker-in-docker` functionality.

Currently Cirrus CI supports running builds on these Kubernetes distributions:

- Google Kubernetes Engine (GKE)
- AWS Elastic Kubernetes Service (EKS)

For Generic Kubernetes Support follow this [issue](https://github.com/cirruslabs/cirrus-ci-docs/issues/211).

### Comparison of docker builds on VMs vs Kubernetes

- VMs
    - complex builds are potentially faster than `docker-in-docker`
    - safer due to better isolation between builds
- Kubernetes
    - much faster start - creating a new container usually takes few seconds vs creating a VM which takes usually about a minute on GCP and even longer on AWS.
    - ability to use an image with your custom tools image (e.g. containing Skaffold) to invoke docker instead of using a fixed VM image.

### How to  

This a full example of how to build a docker image on GKE using docker and pushing it to GCR.
While not required, the script section in this example also has some best practice cache optimizations and pushes the image to GCR.

!!! info "AWS EKS support"
    While the steps below are specifically written for and tested with GKE (Google Kubernetes Engine), it should work equally on AWS EKS.

```yaml
docker_build_task:
  gke_container: # for AWS, replace this with `aks_container`
    image: docker:latest # This image can be any custom image. The only hard requirement is that it needs to have `docker-cli` installed.
    cluster_name: cirrus-ci-cluster # your gke cluster name
    zone: us-central1-b # zone of the cluster
    namespace: cirrus-ci # namespace to use
    cpu: 1
    memory: 1500Mb
    additional_containers:
      - name: dockerdaemon
        privileged: true # docker-in-docker needs to run in privileged mode
        cpu: 4
        memory: 3500Mb
        image: docker:dind
        port: 2375
        env:
          DOCKER_DRIVER: overlay2 # this speeds up the build
          DOCKER_TLS_CERTDIR: "" # disable TLS to preserve the old behavior
  env:
    DOCKER_HOST: tcp://localhost:2375 # this is required so that docker cli commands connect to the "additional container" instead of `docker.sock`.
    GOOGLE_CREDENTIALS: ENCRYPTED[qwerty239abc] # this should contain the json key for a gcp service account with the `roles/storage.admin` role on the `artifacts.<your_gcp_project>.appspot.com` bucket as described here https://cloud.google.com/container-registry/docs/access-control. This is only required if you want to pull / push to gcr. If we use dockerhub you need to use different credentials.
  login_script:
    echo $GOOGLE_CREDENTIALS | docker login -u _json_key --password-stdin https://gcr.io
  build_script:
    - docker pull gcr.io/my-project/my-app:$CIRRUS_LAST_GREEN_CHANGE || true
    - docker build
      --cache-from=gcr.io/my-project/my-app:$CIRRUS_LAST_GREEN_CHANGE
      -t gcr.io/my-project/my-app:$CIRRUS_CHANGE_IN_REPO 
      .   
  push_script:
    - docker push gcr.io/my-project/my-app:$CIRRUS_CHANGE_IN_REPO 
```

### Caveats

Since the `additional_container` needs to run in privileged mode, the isolation between the Docker build and the host are somewhat limited, you should create a separate cluster for Cirrus CI builds ideally.
If this a concern you can also try out [Kaniko](https://github.com/GoogleContainerTools/kaniko) or [Makisu](https://github.com/uber/makisu) to run builds in unprivileged containers.
