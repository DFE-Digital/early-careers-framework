---
title: Getting started
weight: 2
---

# Getting started

The OpenAPI spec from which this documentation is generated is [available in YAML format](/lead-providers/api-docs/v1/api_spec.yml).

## Environments

We have a production environment and a sandbox environment.

The **Lead Provider sandbox** is for testing your integration. When we set you up with an API key, we’ll create a test provider as well.

```
https://ecf-sandbox.london.cloudapps.digital/api/v1
```

The **Production** environment is the real environment. Do not perform testing here.

```
https://manage-training-for-early-career-teachers.education.gov.uk/api/v1
```

## Rate limits

You are limited to 1000 requests per 5 minutes.

This limit is calculated on a rolling basis, per API key. If you exceed the limit, you will see `429` HTTP status codes.

## Authentication

All requests must be accompanied by an `Authorization` request header (not as part of the URL) in the following format: `Authorization: Bearer {token}`

Unauthenticated requests will receive an [UnauthorizedResponse](#unauthorizedresponse-object) with a `401` status code.

## Custom API Headers for Sandbox testing

The sandbox environment supports the following custom header to enable testing: `X-With-Server-Date`

### Using the X-With-Server-Date header

Declaration submissions are made by providers in line with contractual milestones. These are required to fall into specific date periods.

To test the integration more thoroughly, a custom JSON header can be used when making declarations in the sandbox.

This header, `X-With-Server-Date`, is set as a standard JSON header to simulate declaration submissions against future milestone date periods.

It lets you see what would happen when submitting declarations for that time, which would not be valid for the current milestone period, for example, forward declarations, but simulated as current declarations for a later milestone.

This header is only valid on the sandbox system.

Trying to submit future declarations on production systems or without this header would be rejected as part of normal validation.

To set the header:

1. Select header in Postman
2. Set the key to `X-With-Server-Date`
3. Enter the value for your chosen date in ISO8601 'Date with time and Timezone' format, for example `2022-01-10T10:42:00Z`
