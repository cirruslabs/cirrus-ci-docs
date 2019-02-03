# Windows Containers

It is possible to run Windows Containers the same way one can run [Linux containers](linux.md) on Windows Community Cluster. 
Simply use `windows_container` instead of `container` in `.cirrus.yml` files:

```yaml
windows_container:
  image: cirrusci/windowsservercore:2019
  os_version: 2019
  
task:
  script: ...
```

Cirrus CI will execute [scripts instructions](writing-tasks.md#script-instruction) like **Batch scripts**.
    
## OS Versions

By default, Cirrus CI assumes that the container image's host OS is Windows Server 2016. Please specify `os_version`
filed to override it. Cirrus CI support all versions of Windows Containers including: `2016`, `1709`, `1803` and `2019`.

```yaml
windows_container:
  image: cirrusci/windowsservercore:2019
  os_version: 2019
  install_script: choco install -y ...
  ...
```

# Powershell support

By default Cirrus CI agent executed scripts using `cmd.exe`. It is possible to override default shell executor by providing
`CIRRUS_SHELL` [environment variable](writing-tasks.md#environment-variables):

```yaml
env:
  CIRRUS_SHELL: powershell
``` 

It is also possible to use *powershell* scripts inline inside of a script instruction by prefixing it with `ps`:

```yaml
windows_container:
  script:
    - ps: Get-Location
```

`ps: COMMAND` is a simple syntactic sugar which transforms it to 

```bash
powershell.exe -EncodedCommand base64(COMMAND)
```
