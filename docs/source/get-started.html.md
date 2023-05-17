---
title: Get started
weight: 2
---

# Get started

## Connect to the API

Connect to the API by integrating local provider CRM systems with it.

A unique authentication token is needed to connect to the API. Each token is associated with a single provider and will give providers access to CPD participant data.

### Request an authentication token

Providers must [contact us](/api-reference/help) to request a token for production and sandbox environments.

DfE will send a unique authentication token via secure email.

<div class="govuk-warning-text">
  <span class="govuk-warning-text__icon" aria-hidden="true">!</span>
  <strong class="govuk-warning-text__text">
    <span class="govuk-warning-text__assistive">Warning</span>
    Store the authentication tokens securely. Providers must not share tokens in publicly accessible documents or repositories.
  </strong>
</div>

### How to use an authentication token

Include an authentication token in all requests to the API by adding an `Authorization` request header (not as part of the URL) in the following format: 

```
Authorization: Bearer {token}
```

Unauthenticated requests will receive an `UnauthorizedResponse` with a `401` error code.

### Access YAML format API specs

Provider development teams can also access the OpenAPI spec in YAML formats: 

* [View the OpenAPI v1.0.0. spec](/lead-providers/api-docs/v1/api_spec.yml)
* [View the OpenAPI v2.0.0. spec](/lead-providers/api-docs/v2/api_spec.yml)
* [View the OpenAPI v3.0.0. spec](/lead-providers/api-docs/v3/api_spec.yml)

Providers can use API testing tools such as [Postman](https://www.postman.com/) to make test API calls. Providers can import the API as a collection by using Postman's import feature and copying in the YAML URL of the API spec.

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

<div class="govuk-inset-text"> Note, there are some custom API headers that can only be used in sandbox. </div>

* [Test the ability to submit ECF declarations in sandbox ahead of time](/api-reference/ecf/guidance/#test-the-ability-to-submit-declarations-in-sandbox-ahead-of-time)
* [Test the ability to submit NPQ declarations in sandbox ahead of time](/api-reference/npq/guidance/#test-the-ability-to-submit-declarations-in-sandbox-ahead-of-time)



## Rate limits

Providers are limited to 1000 requests per 5 minutes when using the API in the production environment. If the limit is exceeded, providers will see `429` HTTP status codes.

This limit on requests for each authentication key is calculated on a rolling basis. 