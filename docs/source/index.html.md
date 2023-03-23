---
title: About
weight: 1
---

# About

This is API documentation for the Department for Education (DfE)’s new Manage teacher continuing professional development service.

## What this API is for

Once a participant has been added by a school induction tutor, the participant record will become available via the API.

Providers can then use the API for:

- [Retrieving a list of ECF participants](/api-reference/reference-v1#api-v1-participants-ecf-get)
- [Retrieving a CSV file of ECF participants](/api-reference/reference-v1#api-v1-participants-ecf-csv-get)
- [Declaring the progress of an ECF or NPQ participant against milestone](/api-reference/reference-v1#api-v1-participant-declarations-post)
- [Retrieving a list of NPQ applications](/api-reference/reference-v1#api-v1-npq-applications-get)
- [Retrieving a CSV file of NPQ applications](/api-reference/reference-v1#api-v1-npq-applications-csv-get)

## How do I connect to this API?

### Authentication and authorisation

Requests to the API must be accompanied by an authentication token.

Each token is associated with a single provider. It will grant access to participants for courses offered by that provider. You can get a token by writing to [continuing-professional-development@digital.education.gov.uk](href="mailto:continuing-professional-development@digital.education.gov.uk).

For instructions on how to authenticate see the [API reference](/api-reference/developing-on-the-api.html#authentication).

### Versioning

The version of the API is specified in the URL `/api/v{n}/`. For example: `/api/v1/`, `/api/v2/`, `/api/v3/`, ...

When the API changes in a way that is backwards-incompatible, a new version number of the API will be published.

When a new version, for example `/api/v2`, is published, both the previous **v1** and the current **v2** versions will be available.

We, however, only support one version back, so if the **v3** is published, the **v1** will be discontinued.

When non-breaking changes are made to the API, this will not result in a version bump. An example of a non-breaking change could be the introduction of a new field without removing an existing field.

Information about deprecations (for instance attributes/endpoints that will be modified/removed) will be included in the API response through a ‘Warning’ header.

## Testing

To get familiar with our system and perform testing, you can use [our sandbox environment](https://ecf-sandbox.london.cloudapps.digital).
