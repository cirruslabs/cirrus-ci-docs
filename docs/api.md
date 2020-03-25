# Cirrus CI API

Cirrus CI exposes GraphQL API for integrators to use through `https://api.cirrus-ci.com/graphql` endpoint. Please check
[Cirrus CI GraphQL Schema](https://github.com/cirruslabs/cirrus-ci-web/blob/master/schema.graphql) for a full list of 
available types and methods. Or check [built-in interactive GraphQL Explorer](http://cirrus-ci.com/explorer). Here is an example of how to get a build for a particular SHA of a given repository:

```bash
curl -X POST --data \
'{
  "query": "query BuildBySHAQuery($owner: String!, $name: String!, $SHA: String) { searchBuilds(repositoryOwner: $owner, repositoryName: $name, SHA: $SHA) { id } }",
  "variables": {
    "owner": "ORGANIZATION",
    "name": "REPOSITORY NAME",
    "SHA": "SOME SHA"
  }
}' \
https://api.cirrus-ci.com/graphql | python -m json.tool
```

## Authorization

In order for a tool to access Cirrus CI API, an organization admin should generate an access token through Cirrus CI
Settings page for a corresponding organization. Here is a direct link to the settings page: `https://cirrus-ci.com/settings/github/<ORGANIZATION>`. Access tokens will allow full write and read access to both public and private repositories of your organization on Cirrus CI: it will be possible to create new builds and perform any other GraphQL mutations. If you only need read access to public repositories of your organizaion you can skip this step and don't provide `Authorization` header.

Once an access token is generated and securely stored, it can be used to authorize API requests by setting `Authorization`
header to `Bearer $TOKEN`.

## WebHooks

It is possible to subscribe for updates of builds and tasks. If a WebHook URL is configured on Cirrus CI Settings page for 
an organization, Cirrus CI will try to `POST` a webhook event payload to this URL.

`POST` request will contain `X-Cirrus-Event` header to specify if the update was made to a `build` or a `task`. The event 
payload itself is pretty simple:

```json
{
  "action": "created" | "updated",
  "data": ...
}
```

`data` field will be populated by executing the following GraphQL query:

```graphql
repository(id: $repositoryId) {
  id
  owner
  name
  isPrivate
}
build(id: $buildId) {
  id
  branch
  pullRequest
  changeIdInRepo
  changeTimestamp
  status
}
task(id: $taskId) {
  id
  name
  status
  statusTimestamp
  creationTimestamp
  uniqueLabels
  automaticReRun
  automaticallyReRunnable
}
```

!!! info "Custom GraphQL Query"
    If you'd like to customize GraphQL query which will be executed and included in the event payload please contact support
    for further details.
