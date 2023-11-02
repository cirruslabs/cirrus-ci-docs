# Cirrus CI API

Cirrus CI exposes GraphQL API for integrators to use through `https://api.cirrus-ci.com/graphql` endpoint. Please check
[Cirrus CI GraphQL Schema](https://github.com/cirruslabs/cirrus-ci-web/blob/master/schema.gql) for a full list of 
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

In order for a tool to access Cirrus CI API, an organization admin should generate an access token through Cirrus CI settings page
for a corresponding organization. Here is a direct link to the settings page: `https://cirrus-ci.com/settings/github/<ORGANIZATION>`.
An access token will allow full write and read access to both public and private repositories of your organization on Cirrus CI:
it will be possible to create new builds and perform any other GraphQL mutations. It is also possible to generate scoped
access tokens for a subset of repositories to perform read or write operations on the same settings page.

Note that if you only need read access to public repositories of your organization you can skip this step and don't provide `Authorization` header.

Once an access token is generated and securely stored, it can be used to authorize API requests by setting `Authorization`
header to `Bearer $TOKEN`.

!!! note "User API Token Permission Scope"
    It is also possible to generate API tokens for personal accounts but they will be scoped **only** to access personal public and private repositories
    of a particular user. It won't be possible to access private repositories of an organization, _even if_ they have access.

## WebHooks

### Builds and Tasks WebHooks

It is possible to subscribe for updates of builds and tasks. If a WebHook URL is configured on Cirrus CI Settings page for 
an organization, Cirrus CI will try to `POST` a webhook event payload to this URL.

`POST` request will contain `X-Cirrus-Event` header to specify if the update was made to a `build` or a `task`. The event 
payload itself is pretty basic:

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
  durationInSeconds
  changeIdInRepo
  changeTimestamp
  status
}
task(id: $taskId) {
  id
  name
  nameAlias
  status
  statusTimestamp
  creationTimestamp
  durationInSeconds
  uniqueLabels
  automaticReRun
  automaticallyReRunnable
  notifications {
    level
    message
    link
  }
}
```

### Audit Events WebHooks

In addition to updates to builds and tasks, Cirrus CI will also send `audit_event` events to the configured WebHook URL.
`action` for these audit events will be always `"create"` and the `data` field will contain the following GraphQL fragment
for the particular audit event:

```graphql
fragment AuditEventWebhookPayload on AuditEventType {
  id
  type
  timestamp
  data
  actor {
    id
  }
  repository {
    id
    owner
    name
    isPrivate
  }
}
```

Here is an example of an audit event for when a user re-ran a task with an attached Terminal within your organization:

```json
{
  "action": "created" | "updated",
  "data": {
    "id": "uuid-uuid-uuid-uuid",
    "type": "graphql.mutation",
    "timestamp": ...,
    "data": "{\n  \"mutationName\": \"TaskReRun\",\n  \"taskId\": \"1\",\n  \"attachTerminal\": true,\n  \"newTaskId\": 2\n}",
    "actor": {
      "id": "..." // internal to Cirrus CI user Id
    },
    "repository": {
      "id": "123",
      "owner": "ACME",
      "name": "super-project",
      "isPrivate": true
    }
  }
}
```

At the moment only two types of audit events are supported:

* `graphql.mutation` - any GraphQL mutation was performed for your organization (re-running tasks, creating an encrypted variable, etc.).
* `user.authenticated` - a user that has access to your organization logs in to Cirrus CI.

### Securing WebHooks

Imagine you've been given a `https://example.com/webhook` endpoint by your administrator, and for some reason there's no easy way to change that. This kind of URL is easily discoverable on the internet, and an attacker can take advantage of this by sending requests to this URL, thus pretending to be the Cirrus CI.

To avoid such situations, set the secret token in the repository settings, and then validate the `X-Cirrus-Signature` for each WebHook request.

Once configured, the secret token and the request's body are fed into the HMAC algorithm to generate the `X-Cirrus-Signature` for each request coming from the Cirrus CI.

!!! attention "Missing X-Cirrus-Signature header"
    When secret token is configured in the repository settings, all WebHook requests will contain the `X-Cirrus-Signature-Header`. Make sure to assert the presence of `X-Cirrus-Signature-Header` header and correctness of its value in your validation code.

Using HMAC is pretty straightforward in many languages, here's an example of how to validate the `X-Cirrus-Signature` using Python's [`hmac` module](https://docs.python.org/3/library/hmac.html):

```python
import hmac

def is_signature_valid(secret_token: bytes, body: bytes, x_cirrus_signature: str) -> bool:
    expected_signature = hmac.new(secret_token, body, "sha256").hexdigest()

    return hmac.compare_digest(expected_signature, x_cirrus_signature)
```
