This is API documentation for the Department for Education (DfE)’s new Manage teacher continuing professional development service.

## What this API is for

Once a participant has been added by a school induction tutor, the participant record will become available over the API.

Providers can then use the API for:

- [Retrieving a list of ECF participants](./reference#get-api-v1-participants)
- [Retrieving a CSV file of ECF participants](./reference#get-api-v1-participants-csv)
- [Declaring an ECF participant has started](./reference#post-api-v1-participant-declarations)

## How do I connect to this API?

### Authentication and authorisation

Requests to the API must be accompanied by an authentication token.

Each token is associated with a single provider. It will grant access to participants for courses offered by that provider. You can get a token by writing to <continuing-professional-development@digital.education.gov.uk>.

For instructions on how to authenticate see the [API reference](./reference#authentication).

### Versioning

The version of the API is specified in the URL `/api/v{n}/`. For example: `/api/v1/`, `/api/v2/`, `/api/v3/`, ...

When the API changes in a way that is backwards-incompatible, a new version number of the API will be published.

When a new version, for example `/api/v2`, is published, both the previous **v1** and the current **v2** versions will be supported.

We, however, only support one version back, so if the **v3** is published, the **v1** will be discontinued.

When non-breaking changes are made to the API, this will not result in a version bump. An example of a non-breaking change could be the introduction of a new field without removing an existing field.

Information about deprecations (for instance attributes/endpoints that will be modified/removed) will be included in the API response through a ‘Warning’ header.

We will update our [release notes](./release-notes) with all breaking and non-breaking changes.

## Testing

To get familiar with our system and perform testing, you can use [our sandbox environment](https://ecf-sandbox.london.cloudapps.digital).
