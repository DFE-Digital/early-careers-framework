---
title: Get started
weight: 2
---

# Get started

Connect to the API by integrating local provider CRM systems with it.

Provider development teams can access the OpenAPI spec [in YAML format](/lead-providers/api-docs/v1/api_spec.yml).

## Connect to the API

A unique authentication token is needed to connect to the API. Each token is associated with a single provider and will give providers access to CPD participant data.

### Request an authentication token

Providers should [contact us](/api-reference/help) to request a token for production and sandbox environments.

DfE will send a unique authentication token via secure email.

### How to use an authentication token

An authentication token must be included in all requests to the API. 

All requests must contain an `Authorization` request header (not as part of the URL) in the following format:  

```
Authorization: Bearer {token}
```

Unauthenticated requests will receive an `UnauthorizedResponse` with a `401` error code.

## Production and sandbox environments

The API is available via production (live) and sandbox (testing) environments.

### Production environment

The production environment is the live environment which processes real data.  

<div class="govuk-inset-text"> Do not perform testing in the production environment as real participant and payment data may be affected.</div>

```
API v1: 
https://manage-training-for-early-career-teachers.education.gov.uk/api/v1
```

```
API v2:
https://manage-training-for-early-career-teachers.education.gov.uk/api/v2
```

```
API v3: 
https://manage-training-for-early-career-teachers.education.gov.uk/api/v3
```

### Sandbox environment

The sandbox environment is used to test API integrations without affecting real data. 

<div class="govuk-inset-text"> Note, there are some custom API headers that can only be used in sandbox. </div>

Find guidance on how to test declaration submissions in sandbox ahead of time for [ECF](/api-reference/ecf/guidance/#test-the-ability-to-submit-declarations-in-sandbox-ahead-of-time) and [NPQ](/api-reference/npq/guidance/#test-the-ability-to-submit-declarations-in-sandbox-ahead-of-time). 


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

## Rate limits

Providers are limited to 1000 requests per 5 minutes when using the API in the production environment. If the limit is exceeded, providers will see `429` HTTP status codes.

This limit on requests for each authentication key is calculated on a rolling basis. 