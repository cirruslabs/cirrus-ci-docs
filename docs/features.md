## Free for Open Source 

To support Open Source community Cirrus CI provides [Linux](guide/linux.md), [Windows](guide/windows.md), [macOS](guide/macOS.md) and [FreeBSD](guide/FreeBSD.md)
services free of charge.

## Per-second billing

Use [compute credits](pricing.md#compute-credits) to run as many parallel tasks as you want and pay only for CPU time
used by these tasks. Or [bring your own infrastructure](#bring-you-own-infrastructure) and pay directly to your cloud provider
within your current billing.

## No concurrency limit. No queues

Cirrus CI leverages elasticity of the modern clouds to always have available resources to process your builds.
**Engineers should never wait for builds to start**.

## Bring you own infrastructure 

Cirrus CI allows to [bring your own infrastructure](guide/supported-computing-services.md) for your full control over security and for easy of integration with
your current workflow.

<p align="center">
  <a href="/guide/supported-computing-services#google-cloud">
    <img style="width:128px;height:128px;" src="/assets/images/gcp/Google Cloud Platform.svg"/>
  </a>
  <a href="/guide/supported-computing-services#aws">
    <img style="width:128px;height:128px;" src="/assets/images/aws/AWS.svg"/>
  </a>
  <a href="/guide/supported-computing-services#azure">
    <img style="width:128px;height:128px;" src="/assets/images/azure/Microsoft Azure.svg"/>
  </a>
</p>

## Flexible execution environment
 
Cirrus CI allows to use any Unix or Windows VMs, any Docker containers, any amount of CPUs, optional SSDs and GPUs.

## Simple but very powerful configuration format 

Learn more about how to configure tasks [here](guide/writing-tasks.md). Configure things like:

  * [Matrix Builds](guide/writing-tasks.md#matrix-modification)
  * [Dependencies between tasks](guide/writing-tasks.md#dependencies)
  * [Conditional Task Execution](guide/writing-tasks.md#conditional-task-execution)
  * [Local HTTP Cache](guide/writing-tasks.md#http-cache)

Check [Quick Start](guide/quick-start.md) guide for more features.

## Comparison with popular CIaaS

Here is a high level comparison with popular continuous-integration-as-a-service solutions:

Name      | Linux Support           | Windows Support         | macOS Support             | FreeBSD Support            | Customizable CPU/Memory | Pricing
----------| ----------------------  | ----------------------- | ------------------------  | ------------------------ | ----------------------- | -----------------------
Cirrus CI | [:white_check_mark:][1] | [:white_check_mark:][2] | [:white_check_mark:][3]   | [:white_check_mark:][4]  | :white_check_mark:      | Only for used resources + [discounts][5]
Travis CI | :white_check_mark:      | :white_check_mark:      | :white_check_mark:        | :x:                      | :x:                     | Max parallel builds
Circle CI | :white_check_mark:      | :x:                     | :white_check_mark:        | :x:                      | :white_check_mark:      | Max parallel builds
AppVeyor  | :white_check_mark:      | :white_check_mark:      | :x:                       | :x:                      | :x:                     | Max parallel builds

[1]: guide/linux.md
[2]: guide/windows.md
[3]: guide/macOS.md
[4]: guide/FreeBSD.md
[5]: faq.md#any-discounts

Feel free to [contact support](mailto:support@cirruslabs.org) if you have questions for your particular case.
