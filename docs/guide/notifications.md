Cirrus CI itself doesn't have built-in mechanism to send notifications but, since Cirrus CI is following best practices of
integrating with GitHub, it's possible to configure a GitHub action that will send any kind of notifications.

Here is a full list of curated Cirrus Actions for GitHub including ones to send notifications: [cirrus-actions](https://github.com/cirrus-actions).

### Email Action

It's possible to facilitate GitHub Action's own email notification mechanism to send emails about Cirrus CI failures. 
To enable it, add the following `.github/workflows/email.yml` workflow file:

```YAML
on:
  check_suite:
    type: ['completed']

name: Email about Cirrus CI failures
jobs:
  continue:
    name: After Cirrus CI Failure
    if: >-
      github.event.check_suite.app.name == 'Cirrus CI'
      && github.event.check_suite.conclusion != 'success'
      && github.event.check_suite.conclusion != 'cancelled'
    runs-on: ubuntu-latest
    steps:
      - uses: octokit/request-action@v2.x
        id: get_failed_check_run
        with:
          route: GET /repos/${{ github.repository }}/check-suites/${{ github.event.check_suite.id }}/check-runs?status=completed
          mediaType: '{"previews": ["antiope"]}'
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      - run: |
          echo "Cirrus CI ${{ github.event.check_suite.conclusion }} on ${{ github.event.check_suite.head_branch }} branch!"
          echo "SHA ${{ github.event.check_suite.head_sha }}"
          echo $MESSAGE
          echo "##[error]See $CHECK_RUN_URL for details" && false
        env:
          CHECK_RUN_URL: ${{ fromJson(steps.get_failed_check_run.outputs.data).check_runs[0].html_url }}
```
