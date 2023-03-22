---
title: About the API
weight: 1
---

# About the API

The Department of Education (DfE) has developed an API for the Manage teacher continuing professional development service. 

The API enables lead providers to view, submit and update data associated with Early Career Framework (ECF) based training and national professional qualifications (NPQs). 

The data submitted is then used to facilitate appropriate payment from the DfE to providers.

## What does the API do? 

Once an ECF or NPQ participant has been registered to the service, their participant data becomes available via the API. 

Providers can integrate with the API to view, submit and update various kinds of data. For example, providers can view a list of all participants registered with them, update their details, or notify DfE of the training provided to them for a given milestone by submitting a declaration.

* [How to use the API for ECF](/api-reference/ecf) 
* [How to use the API for NPQ](/api-reference/npq)

## API versions and updates

The DfE works to continually improve the API service and new functionality occasionally becomes available. 

If the API changes in a way that is backwards-incompatible, a new version of the API will be published. This is specified in the URL `/api/v{n}/`. For example, `/api/v1/` or  `/api/v2/` and so on. 

When the DfE publishes a new API version, only one previous version will remain supported. For example, when a `v4` is released then `v2` will be discontinued.

Note, there will be an exception to this rule for API `v3`. DfE will support `v1` for an extended period whilst working with providers on transition plans.

When non-breaking updates (sometimes referred to as backwards compatible updates) are made to the API, it will not be re-versioned. An example of a non-breaking change would be the introduction of a new attribute without removing an existing attribute. 

Summaries of all API updates can be found in the [API release notes](/api-reference/release-notes).

## Who is this guidance for?

This guidance has been created for ECF and NPQ providers who have systems integrated with the API. 

It is reviewed and updated as necessary. [Contact us](/api-reference/help) if you have any questions.