# Windows Containers

It is possible to run Windows Containers the same way one can run [Linux containers](/guide/linux.md) on Community Cluster. Simply use
`windows_container` instead of `container` in `.cirrus.yml` files:

```yaml
windows_container:
  image: cirrusci/windowsservercore:2016
  script: ...
```

Cirrus CI will execute [scripts instructions](/guide/writing-tasks.md#script-instruction) like **Batch scripts**.
    
!!! warning "Limitations"
    At the moment only Docker images based of `microsoft/windowsservercore:ltsc2016` are supported since Windows Containers
    are executed via [Azure Container Instances](/guide/supported-computing-services.md#azure-container-instances) computing
    service.
