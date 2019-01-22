Cirrus CI itself doesn't have built-in mechanism to send notifications but, since Cirrus CI is following best practices of
integrating with GitHub, it's possible to configure a GitHub action that will send any kind of notifications.

Here is a full list of curated Cirrus Actions for GitHub including ones to send notifications: [cirrus-actions](https://github.com/cirrus-actions).

### Email Action

Email GitHub Action allows to send email notifications on Cirrus CI Checks completion. Simply add the following to you
`.github/main.workflow` workflow file:

```
action "Cirrus CI Email" {
  uses = "docker://cirrusactions/email:latest"
  env = {
    APP_NAME = "Cirrus CI"
  }
  secrets = ["GITHUB_TOKEN", "MAIL_FROM", "MAIL_HOST", "MAIL_USERNAME", "MAIL_PASSWORD"]
}
```

Check full documentation [here](https://github.com/cirrus-actions/email).
