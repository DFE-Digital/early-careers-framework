---
title: NPQ usage
weight: 3
---

# NPQ usage

## Contents

* [Continuing the NPQ registration process](#continuing-the-npq-registration-process)
* [About accepting or rejecting an NPQ application](#about-accept-reject-npq-application)
* [Accepting an NPQ application](#accept-npq-application)
* [Rejecting an NPQ application](#reject-npq-application)
* [Handling deferrals](#handling-deferrals)
* [Notifying that an NPQ participant is resuming their course](#resuming-npq-participant)
* [Tell  the DfE that a  participant is changing training schedule on their NPQ course](#notifying-of-npq-schedule-change)
* [Handling applications with changes in circumstances](#handling-changes-circumstances)
* [Retrieving the list of NPQ participant records](#retrieving-npq-participants)
* [Declaring that an NPQ participant has started their course](#declaring-that-an-npq-participant-has-started-their-course)
* [Declaring that an NPQ participant has reached a retained milestone](#declaring-that-an-npq-participant-has-retained-their-course)
* [Declaring that an NPQ participant has completed their course](#declaring-that-an-npq-participant-has-completed-their-course)
* [Declaring that an NPQ participant has withdrawn from their course](#declaring-that-an-npq-participant-has-withdrawn-of-their-course)
* [Removing a declaration submitted in error](#removing-participant-declaration)
* [Listing NPQ participant outcomes](#listing-npq-participant-outcomes)
* [Updating NPQ participant outcomes](#updating-npq-participant-outcomes)

The scenarios on this page show example request URLs and payloads clients can use to take actions via this API. The examples are only concerned with business logic and are missing details necessary for real-world usage. For example, authentication is completely left out.

## Continuing the NPQ registration process

This scenario begins when a participant has been added to the service by registering for an NPQ course via the register for a national professional qualification (NPQ) service.

When the participant has completed the registration process the NPQ application record will show:

* whether the email address has been validated
* whether the TRN is valid
* whether the participant is eligible for funding

Once someone has progressed through the GOV.UK registration process, providers are then able to pull this information and initiate their own suitability and application processes.

### Provider retrieves NPQ application records

Get the NPQ application records.

```
GET /api/v1/npq-applications
```

This will return [multiple NPQ application records](/api-reference/reference-v1#schema-multiplenpqapplicationsresponse).

See [retrieve multiple NPQ applications](api-reference/reference-v1#api-v1-npq-applications-get) endpoint.

### Provider refreshes NPQ application records

Get updated NPQ application records.

```
GET /api/v1/npq-applications?filter[updated_since]=2021-05-13T11:21:55Z
```

This will return [multiple NPQ application records](/api-reference/reference-v1#schema-multiplenpqapplicationsresponse) with the updates to the record included.

See [retrieve multiple NPQ applications](/api-reference/reference-v1#api-v1-npq-applications-get) endpoint.

## About accepting or rejecting an NPQ application

In order for DfE to understand if a person has been successful throughout these processes, we require you to submit an acceptance or rejection status. This will need to be submitted for each participant you wish to train before starting their NPQ course.

Accepting or rejecting a participant is separate and distinct from a “started declaration”, which will be collected as part of the tracking and payment process. More [information about declarations](#declaring-that-an-npq-participant-has-started-their-course) can be found further down this page. We will only be able to make payments for participants who are in an “application accepted” state.

Providers should accept a participant if they have been successful in their NPQ application and you wish to enroll them on their chosen NPQ course. Reasons may include but not limited to:

* participant has had their funding confirmed
* participant is suitable for their chosen NPQ course
* participant has the relevant support from their school

Providers should reject a participant if they have not been successful in their NPQ application. Reasons may include but not limited to:

* participant wishes to go with another provider
* participant wishes to take on another course
* participant no longer wishes to take the course
* participant was not successful in their application process

Regardless of the outcome of the application you must inform the participant of the outcome of their NPQ application. You may wish to provide them with feedback or ideas about next steps.

### Accept an NPQ application

This scenario begins after a participant has been added to the service by registering for an NPQ course

#### Provider accepts an NPQ application

You can accept someone if they have successfully completed all application steps ahead of starting their course.</p>

```
POST /api/v1/npq-applications/{id}/accept
```

Where `{id}` is the `id` of the corresponding NPQ application. 

This returns an [NPQ application record](/api-reference/reference-v1#schema-npqapplicationresponse).

### Reject an NPQ application

This scenario begins after a participant has been added to the service by registering for an NPQ course.

#### Provider rejects an NPQ application

You will need to reject someone if you will be unable to train them. For example they have failed the rest of their application, have decided against studying an NPQ or are unable to secure funding.

```
POST /api/v1/npq-applications/{id}/reject
```

Where `{id}` is the `id` of the corresponding NPQ application. This returns an [NPQ application record](/api-reference/reference-v1#schema-npqapplicationresponse).

### Handling deferrals

If a participant wishes to defer you can accept the participant to show they are enrolled. You should only send the started declaration once the participant has started the course.

### Handling applications with changes in circumstances

There are many possible reasons why there might be a change in circumstances of an application. These may include:

* participant selected incorrect course during their application
* participant made a mistake during their application
* participant now wishes to take another course instead
* participant now wishes to fund their NPQ differently

If there is a mistake in the application for example where a participant registers for a one NPQ programme but wishes to change to another programme after registration. The provider should reject that participant and ask them to re-register on the NPQ registration service and enter the correct details. Once the new application is available you can then accept.

### Retrieving the list of NPQ participant records

This scenario begins after an NPQ participant has been added to the service by a participant and then has their application accepted by the provider.

#### Provider retrieves NPQ participant records

Get the NPQ participant records.

```
GET /api/v1/participants/npq
```

This will return [multiple NPQ participant records](/api-reference/reference-v1#schema-multiplenpqparticipantsresponse).

See [retrieve multiple NPQ participants](/api-reference/reference-v1#api-v1-participants-npq-get) endpoint.

#### Provider refreshes NPQ participant records

Get filtered NPQ participant records.

``` GET /api/v1/participants/npq?filter[updated_since]=2021-05-13T11:21:55Z
```

This will return [multiple NPQ participant records](/api-reference/reference-v1#schema-multiplenpqparticipantsresponse) with the updates to the record included.

See [retrieve multiple NPQ participants](/api-reference/reference-v1#api-v1-participants-npq-get) endpoint.

<%= partial "npq_usage_participant_actions" %>

<%= partial "usage_participant_declarations", locals: { programme: "NPQ" } %>