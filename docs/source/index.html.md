---
title: About the API
weight: 1
---

# About the API

The Department of Education (DfE) has developed an API for the Manage teacher continuing professional development service. 

It lets lead providers view, submit and update data associated with Early Career Framework (ECF) based training. The data submitted is used to facilitate payment from the DfE to providers.

Once an ECF participant has been registered to the service, data associated with them becomes available via the API.

Once integrated with the API, providers can, for example, view and update participant details, or notify DfE that they have completed training by submitting a declaration.

## API versions and updates

The DfE works to continually improve the API service and new functionality occasionally becomes available. Guidance is reviewed and updated as necessary.

If the API changes in a way that is backwards-incompatible, a new version of the API will be published. This is specified in the URL `/api/v{n}/`. For example, `/api/v1/` or  `/api/v2/` and so on. 

When the DfE publishes a new API version, only one previous version will remain supported. For example, when a `v4` is released then `v2` will be discontinued.

Note, there will be an exception to this rule for API `v3`. DfE will support `v1` for an extended period whilst working with providers on transition plans.

When non-breaking updates (sometimes referred to as backwards compatible updates) are made, the API will not be re-versioned. An example of a non-breaking change would be the introduction of a new attribute without removing an existing attribute. 

Summaries of all API updates can be found in the [API release notes](/api-reference/release-notes).

## Changes for the 2025/26 academic year

This is where we could add some content alerting users to the fact that changes are coming in the autumn of 2025. We'd also add a link to a new a section of the API guidance dedicated to informing providers about the upcoming changes.

Alternatively, we could consider adding a notification banner at the top of this page about upcoming changes with a link to more details.

