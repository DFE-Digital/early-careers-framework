---
title: About the API
weight: 1
---

# About the API

Lead providers must use this API to view, submit and update participant data so they receive accurate payments from Department for Education (DfE) for their early career training programme.

Once a participant has been registered to the service by their school, data associated with them becomes available to lead providers via the API.

## API versions and updates

We regularly make improvements and add new functionality to the API. View our [release notes](/api-reference/release-notes) to find out about the latest updates.

If we change the API so it’s no longer able to work with older data or functionality, we’ll publish a new version. This is specified in the `URL /api/v{n}/`. For example, `/api/v1/` or `/api/v2/` and so on. We recommend lead providers use the latest version of the API.

When we publish a new API version, only one previous version will remain supported. For example, when a `v4` is released, `v2` will be discontinued.

Note, there's an exception to this rule for `v3`. We're supporting `v1` for an extended period while we work with providers on transition plans.

When we make non-breaking updates (sometimes referred to as backwards compatible updates), we will not re-version the API. An example of a non-breaking change would be when we introduce a new attribute without removing an existing one. 
