---
hide:
- navigation
---

# General Support

The best way to ask general questions about particular use cases is to email our support team at [support+ci@cirruslabs.org](mailto:support+ci@cirruslabs.org).
Our support team is trying our best to respond ASAP, but there is no guarantee on a response time unless your organization enrolls in [Priority Support](#priority-support).

If you have a feature request or noticed lack of some documentation please feel free to [create a GitHub issue](https://github.com/cirruslabs/cirrus-ci-docs/issues/new/choose).
Our support team will answer it by replying to the issue or by updating the documentation.

# Priority Support

In addition to the general support we provide a *Priority Support* option with guaranteed response times. But most importantly we'll be doing
regular checkins to make sure roadmap for Cirrus CI and other services/software under [`cirruslabs` organization](https://github.com/cirruslabs) is aligned with your company's needs.
You'll be helping to shape the future of software developed by Cirrus Labs!

| Severity | Support Impact                                                                                | First Response Time SLA | Hours | How to Submit                                                                                    |
|----------|-----------------------------------------------------------------------------------------------|-------------------------|-------|--------------------------------------------------------------------------------------------------|
| 1        | Emergency (service is unavailable or completely unusable).                                    | 30 minutes              | 24x7  | Please use urgent email address.                                                                 |
| 2        | Highly Degraded (Important features unavailable or extremely slow; No acceptable workaround). | 4 hours                 | 24x5  | Please use priority email address.                                                               |
| 3        | Medium Impact.                                                                                | 8 hours                 | 24x5  | Please use priority email address.                                                               |
| 4        | Low Impact.                                                                                   | 24 hours                | 24x5  | Please use regular support email address. Make sure to send the email from your corporate email. |

`24x5` means period of time from 9AM on Monday till 5PM on Friday in EST timezone.

<!-- markdownlint-disable MD037 -->
??? note "Support Impact Definitions"
    * **Severity 1** - Cirrus CI or other services is unavailable or completely unusable. An urgent issue can be filed and
      our On-Call Support Engineer will respond within 30 minutes. Example: Cirrus CI showing 502 errors for all users.
    * **Severity 2** - Cirrus CI or other services is Highly Degraded. Significant Business Impact. Important Cirrus CI features are unavailable
      or extremely slowed, with no acceptable workaround.
    * **Severity 3** - Something is preventing normal service operation. Some Business Impact. Important features of Cirrus CI or other services
      are unavailable or somewhat slowed, but a workaround is available. Cirrus CI use has a minor loss of operational functionality.
    * **Severity 4** - Questions or Clarifications around features or documentation. Minimal or no Business Impact. 
      Information, an enhancement, or documentation clarification is requested, but there is no impact on the operation of Cirrus CI or other services/software.

!!! info "How to submit a priority or an urgent issue"
    Once your organization [signs the Priority Support Subscription contract](#how-to-purchase-priority-support-subscription),
    members of your organization will get access to separate support emails specified in your subscription contract.

## Priority Support Pricing

As a company grows, engineering team tend to accumulate knowledge operating and working with Cirrus CI and other services/software provided by Cirrus Labs,
therefore there is less effort needed to support each new seat from our side. On the other hand, Cirrus CI allows to [bring your own infrastructure](guide/supported-computing-services.md)
which increases complexity of the support. As a result we reflected the above challenges in a [tiered pricing model](https://www.rebilly.com/blog/subscription-business-pricing-formulas/#tiered)
based on a seat amount and a type of infrastructure used:

| Seat Amount | Only [managed by us instance types](guide/writing-tasks.md#execution-environment) | [Bring your own infrastructure](guide/supported-computing-services.md) |
|-------------|-----------------------------------------------------------------------------------|------------------------------------------------------------------------|
| 20-100      | $60/seat/month                                                                    | $100/seat/month                                                        |
| 101-300     | $45/seat/month                                                                    | $75/seat/month                                                         |
| 301-500     | $30/seat/month                                                                    | $50/seat/month                                                         |
| 500+        | $15/seat/month                                                                    | $25/seat/month                                                         |

Note that Priority Support Subscription requires a purchase of a minimum of 20 seats even if some of them will be unused.

??? info "What is a seat?"
    A seat is a user that initiates CI builds by pushing commits and/or creating pull requests in a **private** repository.
    It can be a real person or a bot. If you are using [Cron Builds](guide/writing-tasks.md#cron-builds) or creating builds through [Cirrus's API](api.md)
    it will be counted as an additional seat (like a bot).

    If you'd like to get a priority support for your public repositories then the amount of seats will be equal to the amount of members in your organization.

## How to purchase Priority Support Subscription

Please email [sales@cirruslabs.org](mailto:sales@cirruslabs.org), so we can get a support contract in addition to [TOC](legal/terms.md).
The contract will contain a special priority email address for your organization and other helpful information. Sales team will
also schedule a check-in meeting to make sure your engineering team is set for success and Cirrus Labs roadmap aligns with your needs.
