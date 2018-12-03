# Cirrus CI

Cirrus CI makes your development cycle **fast**, **efficient**, and **secure** by leveraging modern cloud technologies. 
Cirrus CI scales with your team and makes shipping software faster and cheaper.

## Key Highlights

* [Free for Open Source](guide/linux.md) or [per-second billing otherwise](/pricing.md).
* No concurrency limit. No queues.
* Bring you own infrastructure by delegating execution directly to [variety of computing services](guide/supported-computing-services.md).
* Flexible execution environment: any Unix or Windows VM, any Docker container, any amount of CPUs, optional SSDs and GPUs.
* Simple but very powerful configuration format. Learn more about how to configure tasks [here](guide/writing-tasks.md). Configure things like:
    - [Matrix Builds](guide/writing-tasks.md#matrix-modification)
    - [Dependencies between tasks](guide/writing-tasks.md#dependencies)
    - [Conditional Task Execution](guide/writing-tasks.md#conditional-task-execution)
    - [Local HTTP Cache](guide/writing-tasks.md#http-cache)

Try Cirrus CI with a [Quick Start](guide/quick-start.md) guide.

## Comparison with popular CIaaS

Here is a high level comparison with popular continuous-integration-as-a-service solutions:

Name      | Linux Support           | Windows Support         | macOS Support             | FreeBSD Support            | Customizable CPU/Memory | Pricing
----------| ----------------------  | ----------------------- | ------------------------  | ------------------------ | ----------------------- | -----------------------
Cirrus CI | [:white_check_mark:][1] | [:white_check_mark:][2] | [:white_check_mark:][3]   | [:white_check_mark:][4]  | :white_check_mark:      | Only for used resources + [discounts][5]
Travis CI | :white_check_mark:      | :white_check_mark:      | :white_check_mark:        | :x:                      | :x:                     | Max parallel builds
Circle CI | :white_check_mark:      | :x:                     | :white_check_mark:        | :x:                      | :white_check_mark:      | Max parallel builds
AppVeyor  | :white_check_mark:      | :white_check_mark:      | :x:                       | :x:                      | :x:                     | Max parallel builds

[1]: /guide/linux.md
[2]: /guide/windows.md
[3]: /guide/macOS.md
[4]: /guide/FreeBSD.md
[5]: /faq.md#any-discounts

Feel free to [contact support](mailto:support@cirruslabs.org) if you have questions for your particular case.
