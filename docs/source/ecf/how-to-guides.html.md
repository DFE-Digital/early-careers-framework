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

For more detailed information see the specifications for this [notify that an ECF participant is taking a break from their course endpoint](/api-reference/reference-v3.html#api-v3-participants-ecf-id-defer-put).

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

For more detailed information see the specifications for this [notify that an ECF participant has resumed training endpoint](/api-reference/reference-v3.html#api-v3-participants-ecf-id-resume-put).

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

For more detailed information see the specifications for this [notify that an ECF participant has withdrawn from training endpoint](/api-reference/reference-v3.html#api-v3-participants-ecf-id-withdraw-put).

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




## Notifying that an ECF participant is changing training schedule

This operation allows the provider to tell the DfE that a participant has changed training schedules on their ECF course.

### Provider changes a participant's schedule

Submit the change of schedule notification to the following endpoint.

```
PUT /api/v1/participants/ecf/{id}/change-schedule
```

This will return an [ECF participant record](/api-reference/reference-v1#schema-ecfparticipantresponse) with the updates to the record included.

See [change schedule of ECF participant](/api-reference/reference-v1#api-v1-participants-ecf-id-change-schedule-put) endpoint.

Where a schedule’s name does not include ‘standard’, we will not apply ‘milestone validation’ to any declarations.

Where milestone validation applies, the API will reject a declaration if it is not submitted during the correct milestone period. It will also reject declarations submitted after the milestone period and the declaration_date set in the milestone period. For example, if a participant is on the ecf-standard-september [schedule](#notifying-of-schedule-change-standard-induction-september), the API would reject a start declaration unless it is submitted during the period 19 November 2021 to 30 November 2021, or submitted afterwards and backdated accordingly.

Providers will still be expected to evidence any declarations and why a participant is following a non-standard induction.






## Declaring that an ECF participant has started their course
This scenario begins after it has been confirmed that an ECF participant is ready to begin their induction training.</p>

### Provider confirms an ECF participant has started
Confirm an ECF participant has started their induction training before Milestone 1.

```
POST /api/v1/participant-declarations
```

With a [request body containing an ECF participant declaration](/api-reference/reference-v1#schema-ecfparticipantstarteddeclaration).

This returns [participant declaration](/api-reference/reference-v1#schema-singleparticipantdeclarationresponse).

This endpoint is idempotent - submitting exact copy of a request will return the same response body as submitting it the first time.

See [confirm ECF participant declarations](/api-reference/reference-v1#api-v1-participant-declarations-post) endpoint.

### Provider records the ECF participant declaration ID
Store the returned ECF participant declaration ID for future management tasks.

## Declaring that an ECF participant has reached a retained milestone
This scenario begins after it has been confirmed that an ECF participant has completed enough of their course to meet a milestone.

### Provider confirms an ECF participant has been retained
Confirm an ECF participant has been retained by the appropriate number of months for this retained event on their ECF course.

An explicit `retained-x` declaration is required to trigger output payments. You should declare this when a participant has reached a particular milestone in line with contractual reporting requirements.

```
POST /api/v1/participant-declarations
```

With a [request body containing an ECF participant retained declaration](/api-reference/reference-v1#schema-ecfparticipantretaineddeclaration).

This returns [participant declaration](/api-reference/reference-v1#schema-singleparticipantdeclarationresponse).

See [confirm ECF participant declarations](/api-reference/reference-v1#api-v1-participant-declarations-post) endpoint.

### Provider records the ECF participant declaration ID
Store the returned ECF participant declaration ID for future management tasks.

## Declaring that an ECF participant has completed their course
This scenario begins after it has been confirmed that an ECF participant has completed their course.

### Provider confirms an ECF participant has completed their course
Confirm an ECF participant has completed their ECF course.

An explicit `completed` declaration is required to trigger output payments. You should declare this when a participant has reached their final milestone and completed their ECF course.

```
POST /api/v1/participant-declarations
```

With a [request body containing an ECF participant completed declaration](/api-reference/reference-v1#schema-ecfparticipantstarteddeclaration).

This returns [participant declaration](/api-reference/reference-v1#schema-singleparticipantdeclarationresponse).

See [confirm ECF participant declarations](/api-reference/reference-v1#api-v1-participant-declarations-post) endpoint.

### Provider records the ECF participant declaration ID
Store the returned ECF participant declaration ID for future management tasks.

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
