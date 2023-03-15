---
title: ECF usage
weight: 2
---

# ECF usage

## Contents

* [Continuing the ECF registration process](#continuing-the-ecf-registration-process)
* [Notifying that an ECF participant is taking a break from their course](#notifying-of-deferral)
* [Notifying that an ECF participant is resuming their course](#notifying-of-resume)
* [Notifying that an ECF participant is changing training schedule](#notifying-of-schedule-change)
* [Notifying that an ECF participant has withdrawn from their course](#notifying-of-withdrawal)
* [Declaring that an ECF participant has started their course](#declaring-that-an-ecf-participant-has-started-their-course)
* [Declaring that an ECF participant has reached a retained milestone](#declaring-that-an-ecf-participant-has-retained-their-course)
* [Declaring that an ECF participant has completed their course](#declaring-that-an-ecf-participant-has-completed-their-course)
* [Listing participant declaration submissions](#listing-participant-declaration-submissions)
* [Removing a declaration submitted in error](#removing-participant-declaration)

The scenarios on this page show example request URLs and payloads clients can use to take actions via this API. The examples are only concerned with business logic and are missing details necessary for real-world usage. For example, authentication is completely left out.

## Continuing the ECF registration process
This scenario begins when an ECF participant has been added to the service by a school induction tutor via the manage training for early career teachers service.

### Provider retrieves ECF participant records

Get the ECF participant records.

```
GET /api/v1/participants/ecf
```

This will return [multiple ECF participant records](/api-reference/reference-v1#schema-multipleecfparticipantsresponse).

See [retrieve multiple ECF participants](/api-reference/reference-v1#api-v1-participants-ecf-get) endpoint.

### ECF Participant enters registration details on register for early career framework service

A participant is invited to continue their registration by validating their TRN and contact details.

When the participant has completed this step the ECF participant record will show:
* whether the email address has been validated
* whether the TRN is valid
* whether the participant has achieved QTS status
* whether the participant is eligible for funding

### Provider refreshes ECF participant records

Get updated ECF participant records.

```
GET /api/v1/participants/ecf?filter[updated_since]=2021-05-13T11:21:55Z
```

This will return [multiple ECF participant records](/api-reference/reference-v1#schema-multipleecfparticipantsresponse) with the updates to the record included.

See [retrieve multiple participants](/api-reference/reference-v1#api-v1-participants-ecf-get) endpoint.

<%= partial "ecf_usage_participant_actions" %>

<%= partial "usage_participant_declarations", locals: { programme: "ECF" } %>