# Pricing

Cirrus CI is free for Open Source projects. For private projects Cirrus CI charges a monthly fee of **$10 per seat** for orchestrating builds on 
supported [computing services](guide/supported-computing-services.md).

Here is a pricing model of Cirrus CI:

User | Public Repository | Private Repository
--- | --- | ---
Person | Free + Access to [Community Cluster](guide/supported-computing-services.md#community-cluster) | $10/month + Access to [Community Cluster](guide/supported-computing-services.md#community-cluster)
Organization | Free + Access to [Community Cluster](guide/supported-computing-services.md#community-cluster) | $10/seat/month

!!! info "What is a seat?"

    Seat is simply a GitHub user that initiates CI builds by pushing commints and/or creating pull requests in a **private** repository. 
    It can be a real person or a bot.
    
    For example, there are 10 people in your GitHub Organization and only 5 of them are working on several private repositories 
    where Cirrus CI is configured. The rest 5 people are working on public repositories or not pushing changes at all. Let's say [dependabot](https://dependabot.com/) 
    is also configured for these private repositories. 
    
    In that case there are `5 + 1 = 6` seats you need to purchase Cirrus CI plan for.

See all the pricing options on [Cirrus CI's GitHub Marketplace Page](https://github.com/marketplace/cirrus-ci).

All payments will go through [GitHub Marketplace](https://github.com/marketplace) and will be billed according to
[GitHub Marketplace Terms of Service](https://help.github.com/articles/github-marketplace-terms-of-service/#d-payment-billing-schedule-and-cancellation).
