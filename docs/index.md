# Cirrus CI

Cirrus CI makes your development cycle **fast**, **efficient**, and **secure** by leveraging modern cloud technologies. 
Cirrus CI scales with your team and makes shipping software faster and cheaper.

Thousands of engineers and **hundreds of organizations are already using Cirrus CI**. Here are a few most popular usage
patterns from Cirrus CI customers:

<table style="width:100%;box-shadow:none;">
  <tr>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>
      <a style="float: left;" href="#google-cloud" href="https://google.com/">
        <img width="239" src="/assets/images/customers/Google.svg"/>
      </a>
    </td>
    <td>
      Several Google teams are using Cirrus CI for their OSS projects free of charge by using <a href="/guide/linux/">community clusters</a>. 
      Projects vary from small Node.js libraries to complex Rust applications. 
    </td>
  </tr>
  <tr>
    <td>
      <a style="float: left;" href="#google-cloud" href="https://flutter.io/">
        <img width="239" src="/assets/images/customers/Flutter.svg"/>
      </a>
    </td>
    <td>
      <a href="https://flutter.io/">Flutter</a> is a mobile app SDK with almost 50,000 stars on GitHub.
      Flutter team uses <a href="/pricing/#compute-credits">compute credits</a> to get unlimited prioritized builds and
      only pay for resources that these builds used. 
    </td>
  </tr>
  <tr>
    <td>
      <a style="float: left;" href="#google-cloud" href="https://www.sonarsource.com/">
        <img width="239" src="/assets/images/customers/SonarSource.svg"/>
      </a>
    </td>
    <td>
      <a href="https://www.sonarsource.com/">SonarSource</a> is using <a href="/guide/supported-computing-services/">integration with Google Cloud Platform</a>
      to bring their own infrastructure to Cirrus CI. SonarSource runs their integration tests in parallel on more than 
      a hundred dedicated VMs to get test results in minutes rather than hours.
    </td>
  </tr>
  <tr>
    <td></td>
    <td></td>
  </tr>
</table>

## Key Highlights

* Free for Open Source ([Linux](guide/linux.md), [Windows](guide/windows.md), [macOS](guide/macOS.md) and [FreeBSD](guide/FreeBSD.md))
* [Per-second billing](/pricing.md) for private projects.
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
