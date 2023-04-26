---
title: About the API
weight: 1
---

# About the API

The Department of Education (DfE) has developed an API for the Manage teacher continuing professional development service. 

The API lets lead providers view, submit and update data associated with Early Career Framework (ECF) based training and national professional qualifications (NPQs). The data submitted is used to facilitate payment from the DfE to providers.

Once an ECF or NPQ participant has been registered to the service, data associated with them becomes available via the API.

Once integrated with the API, providers can, for example, view and update participant details, or notify DfE that they have completed training by submitting a declaration.

## API versions and updates

The DfE works to continually improve the API service and new functionality occasionally becomes available. 

If the API changes in a way that is backwards-incompatible, a new version of the API will be published. This is specified in the URL `/api/v{n}/`. For example, `/api/v1/` or  `/api/v2/` and so on. 

When the DfE publishes a new API version, only one previous version will remain supported. For example, when a `v4` is released then `v2` will be discontinued.

Note, there will be an exception to this rule for API `v3`. DfE will support `v1` for an extended period whilst working with providers on transition plans.

When non-breaking updates (sometimes referred to as backwards compatible updates) are made, the API will not be re-versioned. An example of a non-breaking change would be the introduction of a new attribute without removing an existing attribute. 

Summaries of all API updates can be found in the [API release notes](/api-reference/release-notes).

All API requests are available in JSON and CSV formats.

## About this guidance

This guidance has been created for ECF and NPQ providers who have systems integrated with the API. It is reviewed and updated as necessary. 

<div class="govuk-inset-text">The guidance is written for providers integrated with [API version 3.0.0](/api-reference/reference-v3.html). All endpoints reference `v3`. Providers can view specifications for the API version their systems are integrated with.</div>

