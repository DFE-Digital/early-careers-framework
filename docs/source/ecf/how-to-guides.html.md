---
title: How to guides
---

# How to guides

The focus of the following guidance is on business logic only. Critical details which would be necessary for real-world usage have been left out. For example, [authentication](LINK NEEDED) is not detailed.

This guidance is API version-generic, and therefore all endpoints include reference to  
`v{n}`. Providers should amend this according to the API version their systems are integrated with, for example `v2`. 

## When to use the API throughout a participant’s training

1. For a given cohort, providers will submit confirmations via the API of their partnerships with a school, including confirmation who their delivery partners will be. Note, this only applies to providers integrated with API v3 onwards 
2. School induction tutors will register participants for ECF-based training via the DfE online service
3. Providers will view participant data via the API, using it to onboard participants to their learning management systems. Note, the API will not present any data for participants whose details have not been validated by DfE 
4. Providers will train participants as per details set out in their contract
5. Providers will submit a `started` declaration via the API to notify DfE that training has begun 
6. DfE will pay providers output payments for `started` declarations
7. Providers continue to train participants as per details set out in the contract
8. Providers will submit `retained` declarations via the API to notify DfE participants have continued in training for a given milestone
9. DfE will pay providers output payments for `retained` declarations
10. Providers complete training participants as per details set out in the contract
11. Providers will submit `completed` declarations via the API to notify DfE the participant has completed training
12. DfE will pay providers output payments for `completed` declarations

Changes can happen during training; some participants may not complete their training within the standard schedule, or at all. Providers will need to [update relevant data using the API](LINK NEEDED). 

## How to view and update participant data

Providers can view data to find out whether participants:

* have valid email addresses
* have valid teacher reference numbers (TRN) 
* have achieved qualified teacher status (QTS)
* are eligible for funding
* have transferred to or from a school you are partnered with 

Providers can then update data to confirm participants have: 

* deferred training 
* resumed training 
* withdrawn from training 
* changed their training schedule

### View all participant data

View all ECF participant records by using the endpoint: 

```
 GET /api/v{n}/participants/ecf
```

Note, providers can also filter results by adding `cohort` and `updated_since` filters to the parameter. For example: `GET /api/v{n}/participants/ecf?filter[cohort]=2022&filter[updated_since]=2020-11-13T11:21:55Z`

An example response body is listed below. 

For more detailed information see the specifications for this [view multiple ECF participants endpoint](/api-reference/reference-v3.html#api-v3-participants-ecf-get).

#### Example response body:

```
{
  "data": [
    {
      "id": "db3a7848-7308-4879-942a-c4a70ced400a",
      "type": "participant",
      "attributes": {
        "full_name": "Jane Smith",
        "teacher_reference_number": "1234567",
        "updated_at": "2021-05-31T02:22:32.000Z",
        "ecf_enrolments": [
          {
            "training_record_id": "000a97ff-d2a9-4779-a397-9bfd9063072e",
            "email": "jane.smith@some-school.example.com",
            "mentor_id": "bb36d74a-68a7-47b6-86b6-1fd0d141c590",
            "school_urn": "106286",
            "participant_type": "ect",
            "cohort": "2021",
            "training_status": "active",
            "participant_status": "active",
            "teacher_reference_number_validated": true,
            "eligible_for_funding": true,
            "pupil_premium_uplift": true,
            "sparsity_uplift": true,
            "schedule_identifier": "ecf-standard-january",
            "validation_status": "eligible_to_start",
            "delivery_partner_id": "cd3a12347-7308-4879-942a-c4a70ced400a",
            "withdrawal": null,
            "deferral": null,
            "created_at": "2021-05-31T02:22:32.000Z"
          }
        ]
      }
    }
  ]
}
```

### View a single participant's data

View a participant’s data by using the endpoint:

```
 GET /api/v{n}/participants/ecf/{id}
```

An example response body is listed below. 

For more detailed information see the specifications for this [view a single ECF participant endpoint](/api-reference/reference-v3.html#api-v3-participants-ecf-id-get).

#### Example response body:

```
{
  "data": {
    "id": "db3a7848-7308-4879-942a-c4a70ced400a",
    "type": "participant",
    "attributes": {
      "full_name": "Jane Smith",
      "teacher_reference_number": "1234567",
      "updated_at": "2021-05-31T02:22:32.000Z",
      "ecf_enrolments": [
        {
          "training_record_id": "000a97ff-d2a9-4779-a397-9bfd9063072e",
          "email": "jane.smith@some-school.example.com",
          "mentor_id": "bb36d74a-68a7-47b6-86b6-1fd0d141c590",
          "school_urn": "106286",
          "participant_type": "ect",
          "cohort": "2021",
          "training_status": "active",
          "participant_status": "active",
          "teacher_reference_number_validated": true,
          "eligible_for_funding": true,
          "pupil_premium_uplift": true,
          "sparsity_uplift": true,
          "schedule_identifier": "ecf-standard-january",
          "validation_status": "eligible_to_start",
          "delivery_partner_id": "cd3a12347-7308-4879-942a-c4a70ced400a",
          "withdrawal": null,
          "deferral": null,
          "created_at": "2021-05-31T02:22:32.000Z"
        }
      ]
    }
  }
}
```

### Notify DfE a participant has taken a break (deferred) from training

A participant can choose to take a break from ECF-based training at any time if they plan to resume training at a later date. 

Confirm a participant has deferred training by using the endpoint: 

```
 PUT /api/v{n}/participants/ecf/{id}/defer
```

An example request body is listed below. 

For more detailed information see the specifications for this [notify DfE that an ECF participant is taking a break from their course endpoint](/api-reference/reference-v3.html#api-v3-participants-ecf-id-defer-put).

#### Example request body:

```
{
  "data": {
    "type": "participant-defer",
    "attributes": {
      "reason": "career-break",
      "course_identifier": "ecf-mentor"
    }
  }
}
```

### Notify DfE a participant has resumed training

A participant can choose to resume their ECF-based training at any time if they had previously deferred. 

Notify DfE a participant has resumed training by using the endpoint:

```
 /api/v{n}/participants/ecf/{id}/resume
```

An example request body is listed below. Successful requests will return a response body including updates.

For more detailed information see the specifications for this [notify DfE that an ECF participant has resumed training endpoint](/api-reference/reference-v3.html#api-v3-participants-ecf-id-resume-put).

#### Example request body:

```
{
  "data": {
    "type": "participant-resume",
    "attributes": {
      "course_identifier": "ecf-mentor"
    }
  }
}
```

###  Notify DfE a participant has withdrawn from training

A participant can choose to withdraw from ECF-based training at any time.

Notify DfE a participant has withdrawn from training by using the endpoint: 

```
 PUT /api/v{n}/participants/ecf/{id}/withdraw
```

An example request body is listed below. Successful requests will return a response body including updates to the `training_status` attribute.

For more detailed information see the specifications for this [notify DfE that an ECF participant has withdrawn from training endpoint](/api-reference/reference-v3.html#api-v3-participants-ecf-id-withdraw-put).

#### Example request body:

```
{
  "data": {
    "type": "participant-withdraw",
    "attributes": {
      "reason": "left-teaching-profession",
      "course_identifier": "ecf-mentor"
    }
  }
}
```

#### Providers should note: 

* The API will not allow withdrawals for participants who have not had a started declaration submitted against them. If a participant withdraws before a started declaration has been submitted, providers should inform their contract manager who can advise
* DfE will only pay for participants who have had, at a minimum, a started declaration submitted against them
* If a participant is withdrawn later in their training, DfE will pay providers for any declarations submitted where the declaration_date is before the date of the withdrawal
* The amount DfE will pay depends on which milestones have been reached and declarations submitted before the participant withdraws. [View ECF schedules and milestone dates](LINK NEEDED) 

### Notify DfE a participant has changed their training schedule

Participants can choose to follow [standard or non-standard training schedules](LINK NEEDED). Providers must notify the DfE of any schedule change.

Notify DfE a participant has changed their training schedule by using the endpoint:

```
 PUT /api/v3/participants/ecf/{id}/change-schedule
```

An example request body is listed below. Successful requests will return a response body including updates to the `schedule_identifier` attribute.

For more detailed information see the specifications for this [notify that an ECF participant has changed their training schedule endpoint](/api-reference/reference-v3.html#api-v3-participants-ecf-id-change-schedule-put).

#### Example request body:

```
{
  "data": {
    "type": "participant-change-schedule",
    "attributes": {
      "schedule_identifier": "ecf-standard-january",
      "course_identifier": "ecf-mentor",
      "cohort": "2021"
    }
  }
}
```

#### Providers should note: 

Milestone validation applies. The API will reject a schedule change request if any previously submitted declarations (`eligible`, `payable` or `paid`) have a `declaration_date` which does not align with the new schedule’s milestone dates. 

Where this occurs, providers should:

1. void the existing declarations (where declaration_date does not align with the new schedule)
2. change the participant’s training schedule 
3. resubmit backdated declarations (where declaration_date aligns with the new schedule)


## How to submit, view and void declarations

Providers must submit declarations in line with ECF contractual [schedules and milestone dates](LINK NEEDED). These declarations will trigger payment from DfE to providers. 

Providers must submit declarations in line with ECF contractual [schedules and milestone dates](LINK NEEDED). These declarations will trigger payment from DfE to providers. 
### Test the ability to submit declarations in sandbox ahead of time 

`X-With-Server-Date` is a custom JSON header supported in the sandbox environment. It lets providers test their integrations and ensure they are able to submit declarations for future milestone dates.

The `X-With-Server-Date` header lets providers simulate future dates, and therefore allows providers to test declaration submissions for future milestone dates. 

It is only valid in the sandbox environment. Attempts to submit future declarations in the production environment (or without this header in sandbox) will be rejected as part of milestone validation.

To test declaration submission functionality, include: 

* the header `X-With-Server-Date` as part of declaration submission request
* the value of your chosen date in ISO8601 Date with time and Timezone (i.e. RFC3339 format). For example: 

```
X-With-Server-Date: 2022-01-10T10:42:00Z
```

### Notify DfE a participant has started training

To notify DfE that a participant has started ECF-based training, providers must submit a `started` declaration in line with [milestone 1 dates](LINK NEEDED).

Confirm a participant has started training by using the endpoint: 

```
 POST /api/v3/participant-declarations
```

Request bodies must include the necessary data attributes, including the `declaration_type` attribute with a `started` value. An example request body is listed below.

Successful requests will return a response body with declaration data. An example response body is listed below. Any attempts to submit duplicate declarations will return an error message.

For more detailed information see the specifications for this [notify DfE that an ECF participant has started training endpoint](/api-reference/reference-v3.html#api-v3-participant-declarations-post).

#### Example request body:

```
{
  "data": {
    "type": "participant-declaration",
    "attributes": {
      "participant_id": "db3a7848-7308-4879-942a-c4a70ced400a",
      "declaration_type": "started",
      "declaration_date": "2021-05-31T02:21:32.000Z",
      "course_identifier": "ecf-induction"
    }
  }
}
```

#### Example response body:

```
{
  "data": {
    "id": "db3a7848-7308-4879-942a-c4a70ced400a",
    "type": "participant-declaration",
    "attributes": {
      "participant_id": "08d78829-f864-417f-8a30-cb7655714e28",
      "declaration_type": "started",
      "declaration_date": "2020-11-13T11:21:55Z",
      "course_identifier": "ecf-induction",
      "state": "eligible",
      "updated_at": "2020-11-13T11:21:55Z",
      "created_at": "2020-11-13T11:21:55Z",
      "delivery_partner_id": "99ca2223-8c1f-4ac8-985d-a0672e97694e",
      "statement_id": "99ca2223-8c1f-4ac8-985d-a0672e97694e",
      "clawback_statement_id": null,
      "ineligible_for_funding_reason": null,
      "mentor_id": "907f61ed-5770-4d38-b22c-1a4265939378",
      "uplift_paid": true,
      "evidence_held": "other"
    }
  }
}
```

Note, providers should store the returned ECF participant declaration ID for management tasks.

### Notify DfE a participant has been retained in training

To notify DfE that a participant has reached a given retention point in their training, providers must submit a `retained` declaration in line with [milestone dates](LINK NEEDED).

Confirm a participant has been retained in training by using the endpoint:

```
POST /api/v{n}/participant-declarations
```

Request bodies must include the necessary data attributes, including the appropriate `declaration_type` attribute value, for example `retained-1`. An example request body is listed below.

Successful requests will return a response body with declaration data. An example response body is listed below. Any attempts to submit duplicate declarations will return an error message.

For more detailed information see the specifications for this [notify DfE that an ECF participant has started training endpoint](/api-reference/reference-v3.html#api-v3-participant-declarations-post).

#### Example request body:

```
{
  “data”: {
    “type”: “participant-declaration”,
    “attributes”: {
      “participant_id”: “db3a7848-7308-4879-942a-c4a70ced400a”,
      “declaration_type”: “retained-1",
      “declaration_date”: “2021-05-31T02:21:32.000Z”,
      “course_identifier”: “ecf-induction”
      “evidence_held”: “training-event-attended”
    }
  }
}
```

#### Example response body:

```
{
  “data”: {
    “id”: “db3a7848-7308-4879-942a-c4a70ced400a”,
    “type”: “participant-declaration”,
    “attributes”: {
      “participant_id”: “08d78829-f864-417f-8a30-cb7655714e28",
      “declaration_type”: “retained-1",
      “declaration_date”: “2021-05-31T02:21:32.000Z”,
      “course_identifier”: “ecf-induction”,
      “state”: “eligible”,
      “updated_at”: “2020-11-13T11:21:55Z”,
      “created_at”: “2020-11-13T11:21:55Z”,
      “delivery_partner_id”: “99ca2223-8c1f-4ac8-985d-a0672e97694e”,
      “statement_id”: “99ca2223-8c1f-4ac8-985d-a0672e97694e”,
      “clawback_statement_id”: null,
      “ineligible_for_funding_reason”: null,
      “mentor_id”: “907f61ed-5770-4d38-b22c-1a4265939378",
      “uplift_paid”: true,
      “evidence_held”: “training-event-attended”
    }
  }
}
```

Note, providers should store the returned ECF participant declaration ID for management tasks.

### Notify DfE a participant has completed training

To notify DfE that a participant has completed their training, providers must submit a `completed` declaration in line with [milestone dates](LINK NEEDED).

Confirm a participant has completed training by using the endpoint:

```
POST /api/v{n}/participant-declarations
```

Request bodies must include the necessary data attributes, including the `declaration_type` attribute with a `completed` value. An example request body is listed below.

Successful requests will return a response body with declaration data. An example response body is listed below. Any attempts to submit duplicate declarations will return an error message.

For more detailed information see the specifications for this [notify DfE that an ECF participant has completed training endpoint](/api-reference/reference-v3.html#api-v3-participant-declarations-post).

#### Example request body:

```
{
  “data”: {
    “type”: “participant-declaration”,
    “attributes”: {
      “participant_id”: “db3a7848-7308-4879-942a-c4a70ced400a”,
      “declaration_type”: “completed”,
      “declaration_date”: “2021-05-31T02:21:32.000Z”,
      “course_identifier”: “ecf-induction”
      “evidence_held”: “self-study-material-completed”
    }
  }
}
```
#### Example response body:

```
{
  “data”: {
    “id”: “db3a7848-7308-4879-942a-c4a70ced400a”,
    “type”: “participant-declaration”,
    “attributes”: {
      “participant_id”: “08d78829-f864-417f-8a30-cb7655714e28",
      “declaration_type”: “completed",
      “declaration_date”: “2021-05-31T02:21:32.000Z”,
      “course_identifier”: “ecf-induction”,
      “state”: “eligible”,
      “updated_at”: “2020-11-13T11:21:55Z”,
      “created_at”: “2020-11-13T11:21:55Z”,
      “delivery_partner_id”: “99ca2223-8c1f-4ac8-985d-a0672e97694e”,
      “statement_id”: “99ca2223-8c1f-4ac8-985d-a0672e97694e”,
      “clawback_statement_id”: null,
      “ineligible_for_funding_reason”: null,
      “mentor_id”: “907f61ed-5770-4d38-b22c-1a4265939378",
      “uplift_paid”: true,
      “evidence_held”: “self-study-material-completed”
    }
  }
}
```

Note, providers should store the returned ECF participant declaration ID for future management tasks.


## Removing a declaration submitted in error
This operation allows the provider to void a participant declaration that has been previously submitted.

This allows the provider to rectify incorrectly/inaccurately reported participant data that may have been submitted in error.

### Provider voids a declaration
Submit the void to the following endpoint

```
PUT /api/v1/participant-declarations/{id}/void
```

This will return a [participant declaration record](/api-reference/reference-v1#schema-singleparticipantdeclarationresponse) with the updates to the record included.

See [void participant declaration](/api-reference/reference-v1#api-v1-participant-declarations-id-void-put) endpoint.

## Listing participant declaration submissions 
This is how you see all the declarations you have made. This functionality allows the provider to check declaration submissions and identify any that are missing.

If declarations are missing, following other guidance by going to [Declaring that an ECF participant started their course](#declaring-that-an-ecf-participant-has-started-their-course).

### Checking all previously submitted declarations
This section lets you review all of the declarations you have made.

All of your submitted declarations are listed.

```
GET /api/v1/participant-declarations
```

This returns [participant declarations](/api-reference/reference-v1#schema-participantdeclarationresponse).

### Checking a single previously submitted declaration 

This section lets you review a single declaration you have made.

```
GET /api/v1/participant-declarations/{id}
```

This returns a [participant declaration](/api-reference/reference-v1#schema-singleparticipantdeclarationresponse).
