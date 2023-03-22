---
title: Getting started
weight: 2
---

# Getting started

Providers can connect to the API by integrating their local systems with it. 

Provider development teams can access the OpenAPI spec [in YAML format](/lead-providers/api-docs/v1/api_spec.yml).

## Connecting to the API

To connect to the API providers will need a unique authentication token.

Each token is associated with a single provider. The authentication token will grant providers access to CPD participant data. 

### Request an authentication token

Providers should [contact us](/api-reference/help) to request a token for production and sandbox environments.

DfE will send each provider a unique authentication token via secure email. 

### How to use an authentication token

An authentication token must be included in all requests to the API. 

Providers should accompany all requests with an `Authorization` request header (not as part of the URL) in the following format: 

```
Authorization: Bearer {token}
```

Unauthenticated requests will receive an `UnauthorizedResponse` with a `401` error code.

## Production and sandbox environments

The API is available via production (live) and sandbox (testing) environments.

### Production environment

The production environment is the live environment which processes real data. 

Do not perform testing in the production environment as real participant and payment data may be affected.

```
https://manage-training-for-early-career-teachers.education.gov.uk/api/v1
```

```
https://manage-training-for-early-career-teachers.education.gov.uk/api/v2
```

```
https://manage-training-for-early-career-teachers.education.gov.uk/api/v3
```

### Sandbox environment

The sandbox environment is used by lead providers to: 

* test API integrations without affecting real data 
* become familiar with the service

```
API v1: 
https://ecf-sandbox.london.cloudapps.digital/api/v1
```

```
API v2:
https://ecf-sandbox.london.cloudapps.digital/api/v2
```

```
API v3: 
https://ecf-sandbox.london.cloudapps.digital/api/v3
```

Note, there are some custom API headers that can only be used in sandbox. Find guidance on how to test declaration submissions in sandbox ahead of time for [ECF](/api-reference/ecf) and [NPQ](/api-reference/npq). 

## Rate limits

Providers are limited to 1000 requests per 5 minutes when using the API in the production environment. If the limit is exceeded, providers will see `429` HTTP status codes.

This limit on requests for each authentication key is calculated on a rolling basis. 
