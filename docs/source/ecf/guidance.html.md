---
title: Guidance
weight: 2
---

# Guidance

The focus of the following guidance is on business logic only. Critical details which would be necessary for real-world usage have been left out. For example, [authentication](/api-reference/get-started/#connect-to-the-API) is not detailed.

<div class="govuk-inset-text">This guidance is written for API version 3.0.0, and therefore all endpoints reference `v3`. Providers should view specifications for the API version their systems are integrated as appropriate.</div>

## Overview of API requests

1. For a given cohort, providers confirm partnerships with schools via the API, including confirmation who their delivery partners will be. **Note**, this only applies to providers integrated with API v3 onwards
2. School induction tutors register participants for ECF-based training via the DfE online service
3. Providers view participant data via the API, using it to onboard participants to their learning management systems. Note, the API will not present any data for participants whose details have not yet been validated by DfE
4. If necessary, providers will update the participant's training schedule via the API
5. Providers will train participants as per details set out in their contract
6. Providers will submit a `started` declaration via the API to notify DfE that training has begun
7. DfE will pay providers output payments for `started` declarations
8. Providers will check via the API to see whether any participants have transferred to or from schools they are in partnership with. **Note**, this only applies to providers integrated with API v3 onwards
9. Providers continue to train participants as per details set out in the contract
10. Providers will submit `retained` declarations via the API to notify DfE participants have continued in training for a given milestone
11. DfE will pay providers output payments for `retained` declarations
12. Providers complete training participants as per details set out in the contract
13. Providers will submit `completed` declarations via the API to notify DfE the participant has completed training
14. DfE will pay providers output payments for `completed` declarations
15. Providers view financial statements via the API

Changes can happen during training; some participants may not complete their training within the standard schedule, or at all. Providers must update relevant data using the API.

## Confirm, view and update partnerships

<div class="govuk-inset-text">The following endpoints are only available for systems integrated with API v3 onwards. They will not return data for API v1 or v2.</div>

Providers must confirm to the DfE that they have agreed to enter into new partnerships with a school and delivery partner to deliver ECF-based training.

**Providers should note:**

* once a partnership for a cohort is confirmed, any new participants who are registered for training at that school will be assigned ‘default’ training provision. For example, once a provider confirms partnership for the 2024 cohort, any participants who are registered at the school by the induction tutor will default to training with the provider and delivery partner in partnership
* not all participants at a given school will be registered to receive training through the (default) partnership. Therefore providers may not receive data for all participants at schools they have partnered with. For example, a participant begins training at school 1 which is partnered with provider A and delivery partner B. If the participant transfers to school 2 which is partnered with provider Y and delivery partner Z, the participant can choose to remain with their existing training providers (A and B). In this case, provider Y will not receive data for this participant
* providers may receive data for participants at schools which they do not have a partnership with. For example, a participant begins training at school 1 which is partnered with provider Y and delivery partner Z. They transfer to school 2 and choose to remain with their existing training providers (Y and Z). Therefore provider Y will continue to receive data for the participant, despite not being partnered with school 2

### Find schools delivering ECF-based training in a given cohort

View details for schools providing ECF-based training in a given cohort. Check details on the type of training programme schools have chosen to deliver, and whether they have confirmed partnerships in place.

```
GET /api/v3/schools/ecf?filter[cohort]={year}
```

<div class="govuk-inset-text"> The `cohort` filter must be included as a parameter. The API will reject requests which do not include the `cohort` filter. </div>

Providers can also filter results by school URN. For example: `GET /api/v3/schools/ecf?filter[cohort]=2024&filter[urn]=123456`

An example response body is listed below. Successful requests will return a response body with school details.

#### Providers should note:

* the API will **only** show schools that are eligible for funded ECF-based training programmes within a given cohort. For example, if schools are eligible for funding in the 2021 cohort, they will be visible via the API, and providers can go on to form partnerships with them
* the API will **not** show schools that are ineligible for funding in a given cohort. If a school’s eligibility changes from one cohort to the next, results will default according to the latest school eligibility. For example, if a school was eligible for funding in the 2023 cohort but becomes ineligible for funding in 2024, the API will **not** show the school in the 2024 cohort
* funding for the 2021 cohort ends on 31 July 2024. Schools will migrate any participants from this group who've not completed their training to the 2024 cohort

For more detailed information see the specifications for this [view school details endpoint](/api-reference/reference-v3.html#api-v3-schools-ecf-get).

#### Example response body:

```
{
  "data": [
    {
      "id": "cd3a12347-7308-4879-942a-c4a70ced400a",
      "type": "school",
      "attributes": {
        "name": "School Example",
        "urn": "123456",
        "cohort": 2024,
        "in_partnership": "false",
        "induction_programme_choice": "not_yet_known",
        "created_at": "2024-05-31T02:22:32.000Z",
        "updated_at": "2024-05-31T02:22:32.000Z"
      }
    }
  ]
}
```

### View details for specific a school in a given cohort

Providers can view details for a specific school providing ECF-based training in a given cohort. They can check details on the type of training programme the school has chosen to deliver, and whether they have a confirmed partnership in place.


```
GET /api/v3/schools/ecf/{id}?filter[cohort]={year}
```

<div class="govuk-inset-text"> The `cohort` filter must be included as a parameter. The API will reject requests which do not include the `cohort` filter. </div>

An example response body is listed below.Successful requests will return a response body with school details.

For more detailed information see the specifications for this [view a school’s details endpoint](/api-reference/reference-v3.html#api-v3-schools-ecf-id-get).

#### Example response body:

```
{
  "data": [
    {
      "id": "cd3a12347-7308-4879-942a-c4a70ced400a",
      "type": "school",
      "attributes": {
        "name": "School Example",
        "urn": "123456",
        "cohort": 2024,
        "in_partnership": "false",
        "induction_programme_choice": "not_yet_known",
        "created_at": "2024-05-31T02:22:32.000Z",
        "updated_at": "2024-05-31T02:22:32.000Z"
      }
    }
  ]
}
```

### Find delivery partner IDs

Delivery partners are assigned a unique ID by DfE. This `delivery_partner_id` is required when [confirming partnerships with a school and delivery partner](/api-reference/ecf/guidance.html#confirm-a-partnership-with-a-school-and-delivery-partner).

```
GET /api/v3/delivery-partners
```

Note, providers can also filter results by adding a `cohort` filter to the parameter. For example: `GET /api/v3/delivery-partners?filter[cohort]=2024`

An example response body is listed below. Successful requests will return a response body including delivery partner details.

For more detailed information see the specifications for this [find delivery parter IDs endpoint](/api-reference/reference-v3.html#api-v3-delivery-partners-get).

#### Example response body:

```
{
  "data": [
    {
      "id": "cd3a12347-7308-4879-942a-c4a70ced400a",
      "type": "delivery-partner",
      "attributes": {
        "name": "Awesome Delivery Partner Ltd",
        "cohort": [
          "2023",
          "2024"
        ],
        "created_at": "2024-05-31T02:22:32.000Z",
        "updated_at": "2024-05-31T02:22:32.000Z"
      }
    }
  ]
}
```

### View details for a specific delivery partner

View details for a specific delivery partner to check whether they have been registered to deliver training for a given cohort.

```
GET /api/v3/delivery-partners/{id}
```

An example response body is listed below. Successful requests will return a response body with the delivery partner details.

For more detailed information see the specifications for this [find a delivery parter ID endpoint](/api-reference/reference-v3.html#api-v3-delivery-partners-id-get).

#### Example response body:

```
{
  "data": [
    {
      "id": "cd3a12347-7308-4879-942a-c4a70ced400a",
      "type": "delivery-partner",
      "attributes": {
        "name": "Awesome Delivery Partner Ltd",
        "cohort": [
          "2023",
          "2024"
        ],
        "created_at": "2024-05-31T02:22:32.000Z",
        "updated_at": "2024-05-31T02:22:32.000Z"
      }
    }
  ]
}
```

### Confirm a partnership with a school and delivery partner

```
 POST /api/v3/partnerships/ecf
```

An example request body is listed below. Request bodies must include all necessary data attributes, namely `cohort`, `school_id` and `delivery_partner_id`.

An example response body is listed below. Successful requests will return a response body with updates included.

#### Providers should note:

* the API assumes schools intend to work with a given provider for consecutive cohorts. School induction tutors will be prompted to confirm existing partnerships with providers **will continue** into the upcoming cohort. Providers do not need take any action to continue existing partnerships with schools from one cohort to the next
* in order for new providers to confirm partnerships with schools for an upcoming cohorts, school induction tutors must first notify DfE that their schools **will not continue** their former partnerships with existing providers for the upcoming cohort. Until induction tutors have done this, any new partnerships with new providers will be rejected by the API
* you can use POST to create a new partnership once one has been rejected

For more detailed information see the specifications for this [confirm an ECF partnership endpoint.](/api-reference/reference-v3.html#api-v3-partnerships-ecf-post)

#### Example request body:

```
{
  "data": {
    "type": "ecf-partnership",
    "attributes": {
      "cohort": "2024",
      "school_id": "24b61d1c-ad95-4000-aee0-afbdd542294a",
      "delivery_partner_id": "db2fbf67-b7b7-454f-a1b7-0020411e2314"
    }
  }
}
```

#### Example response body:
```
{
  "data": {
    "id": "cd3a12347-7308-4879-942a-c4a70ced400a",
    "type": "partnership",
    "attributes": {
      "cohort": 2024,
      "urn": "123456",
      "school_id": "24b61d1c-ad95-4000-aee0-afbdd542294a",
      "delivery_partner_id": "db2fbf67-b7b7-454f-a1b7-0020411e2314",
      "delivery_partner_name": "Delivery Partner Example",
      "status": "active",
      "challenged_reason": null,
      "challenged_at": null,
      "induction_tutor_name": "John Doe",
      "induction_tutor_email": "john.doe@example.com",
      "updated_at": "2024-05-31T02:22:32.000Z",
      "created_at": "2024-05-31T02:22:32.000Z"
    }
  }
}
```

### View all details for all existing partnership

View details for all existing partnerships to check information is correct and whether any have had their status challenged by schools. [Find out more about partnership statuses.](/api-reference/ecf/definitions-and-states/#partnership-states)

```
GET /api/v3/partnerships/ecf
```

Note, providers can also filter results by adding a `cohort` filter to the parameter. For example: `GET /api/v3/partnerships/ecf?filter[cohort]=2024`

An example response body is listed below.

For more detailed information see the specifications for this [view all ECF partnerships endpoint.](api-reference/reference-v3.html#api-v3-partnerships-ecf-get)

#### Example response body:

```
{
  "data": [
    {
      "id": "cd3a12347-7308-4879-942a-c4a70ced400a",
      "type": "partnership",
      "attributes": {
        "cohort": 2024,
        "urn": "123456",
        "school_id": "dd4a11347-7308-4879-942a-c4a70ced400v",
        "delivery_partner_id": "cd3a12347-7308-4879-942a-c4a70ced400a",
        "delivery_partner_name": "Delivery Partner Example",
        "status": "challenged",
        "challenged_reason": "mistake",
        "challenged_at": "2024-05-31T02:22:32.000Z",
        "induction_tutor_name": "John Doe",
        "induction_tutor_email": "john.doe@example.com",
        "updated_at": "2024-05-31T02:22:32.000Z",
        "created_at": "2024-05-31T02:22:32.000Z"
      }
    }
  ]
}
```

### View details for a specific existing partnership

View details for an existing partnership to check information is correct and whether the status has been challenged by the school. [Find out more about partnership statuses.](/api-reference/ecf/definitions-and-states/#partnership-states)

```
GET /api/v3/partnerships/ecf/{id}
```

An example response body is listed below.

For more detailed information see the specifications for this [view a single ECF partnership endpoint.](/api-reference/reference-v3.html#api-v3-partnerships-ecf-id-get)

#### Example response body:

```
{
  "data": [
    {
      "id": "cd3a12347-7308-4879-942a-c4a70ced400a",
      "type": "partnership",
      "attributes": {
        "cohort": 2024,
        "urn": "123456",
        "school_id": "dd4a11347-7308-4879-942a-c4a70ced400v",
        "delivery_partner_id": "cd3a12347-7308-4879-942a-c4a70ced400a",
        "delivery_partner_name": "Delivery Partner Example",
        "status": "challenged",
        "challenged_reason": "mistake",
        "challenged_at": "2024-05-31T02:22:32.000Z",
        "induction_tutor_name": "John Doe",
        "induction_tutor_email": "john.doe@example.com",
        "updated_at": "2024-05-31T02:22:32.000Z",
        "created_at": "2024-05-31T02:22:32.000Z"
      }
    }
  ]
}
```

### Update a partnership with a new delivery partner

Update an existing partnership with new delivery partner details for a given cohort.

```
 PUT /api/v3/partnerships/ecf/{id}
```

An example request body is listed below. Request bodies must include a new value for the `delivery_partner_id` attribute. If unsure, providers can [find delivery partner IDs](/api-reference/ecf/guidance/#find-delivery-partner-ids).

<div class="govuk-inset-text">Note, providers can only update partnerships where the `status` attribute is `active`. Any requests to update `challenged` partnerships will return an error. If a partnership has been challenged and rejected, use POST to create a new partnership, rather than PUT. </div>

[Find out more about partnership statuses.](/api-reference/ecf/definitions-and-states/#partnership-states)

Successful requests will return a response body with updates included.

For more detailed information see the specifications for this [update an ECF partnership endpoint](/api-reference/reference-v3.html#api-v3-partnerships-ecf-id-put).

#### Example request body:

```
{
  "data": {
    "type": "ecf-partnership-update",
    "attributes": {
      "delivery_partner_id": "db2fbf67-b7b7-454f-a1b7-0020411e2314"
    }
  }
}
```

## View and update participant data

Providers can view data to find out whether participants:

* have valid email addresses
* have valid teacher reference numbers (TRN)
* have achieved qualified teacher status (QTS)
* are eligible for funding
* have [transferred to or from a school you're partnered with](/api-reference/ecf/guidance/#view-data-for-all-participants-who-have-transferred)
* have (if they're ECTs) been assigned [unfunded mentors](/api-reference/ecf/guidance.html#view-all-unfunded-mentor-details)
* have (if they're ECTs) completed their induction, according to the Database of Qualified Teachers

Note, while participants can enter different email addresses when registering for each training course they apply for, providers will only see the email address associated with a given course registration. For example, a participant may complete their ECF-based training with one associated email address, then register for an NPQ with a different email address, and go on to be an ECT mentor with a third email address. DfE will share the relevant email address with the relevant course provider.

Providers can then update data to notify DfE that participants have:

* [deferred training](/api-reference/ecf/guidance/#notify-dfe-a-participant-has-taken-a-break-deferred-from-training )
* [resumed training](/api-reference/ecf/guidance/#notify-dfe-a-participant-has-resumed-training)
* [withdrawn from training](/api-reference/ecf/guidance/#notify-dfe-a-participant-has-withdrawn-from-training)
* [changed their training schedule](/api-reference/ecf/guidance.html#notify-dfe-of-a-participant-39-s-training-schedule)

### View all participant data

```
 GET /api/v{n}/participants/ecf
```

Note, providers can also filter results by adding `cohort` and `updated_since` filters to the parameter. For example: `GET /api/v{n}/participants/ecf?filter[cohort]=2024&filter[updated_since]=2020-11-13T11:21:55Z`

An example response body is listed below.

**Providers should note:**

* DfE has [previously advised](/api-reference/release-notes.html#15-march-2023) of the possibility that participants may be registered as duplicates with multiple participant_ids. Where DfE identifies duplicates, it will fix the error by ‘retiring’ one of the participant IDs, then associating all records and data under the remaining ID
* providers can check if an ECF participant’s ID has changed using the `participant_id_changes` nested structure in the [ECFEnrolment](/api-reference/reference-v3.html#schema-ecfenrolment), which contains a `from_participant_id` and a `to_participant_id` string fields, as well a `changed_at` date value
* DfE will close the funding contract for the 2021 cohort on 31 July 2024. Schools will start moving ECTs and mentors with partial declarations originally assigned to the 2021 cohort to the 2024 cohort from mid-June  

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
        "updated_at": "2024-05-31T02:22:32.000Z",
        "ecf_enrolments": [
          {
            "training_record_id": "000a97ff-d2a9-4779-a397-9bfd9063072e",
            "email": "jane.smith@some-school.example.com",
            "mentor_id": "bb36d74a-68a7-47b6-86b6-1fd0d141c590",
            "school_urn": "106286",
            "participant_type": "ect",
            "cohort": "2024",
            "training_status": "active",
            "participant_status": "active",
            "teacher_reference_number_validated": true,
            "eligible_for_funding": true,
            "pupil_premium_uplift": true,
            "sparsity_uplift": true,
            "schedule_identifier": "ecf-standard-january",
            "delivery_partner_id": "cd3a12347-7308-4879-942a-c4a70ced400a",
            "withdrawal": null,
            "deferral": null,
            "created_at": "2024-05-31T02:22:32.000Z",
            "induction_end_date": "2025-01-12",
            "mentor_funding_end_date": "2024-04-19",
            "cohort_changed_after_payments_frozen": false
          }
        ],
        "participant_id_changes": [
          {
            "from_participant_id": "23dd8d66-e11f-4139-9001-86b4f9abcb02",
            "to_participant_id": "db3a7848-7308-4879-942a-c4a70ced400a",
            "changed_at": "2023-09-23T02:22:32.000Z",
          }
        ]
      }
    }
  ]
}
```

### View a single participant's data

```
 GET /api/v{n}/participants/ecf/{id}
```

An example response body is listed below.

**Providers should note:**

* we’ve [previously advised](/api-reference/release-notes.html#15-march-2023) of the possibility that participants may be registered as duplicates with multiple `participant_ids`. Where we identify duplicates, we’ll fix the error by ‘retiring’ one of the participant IDs and then associating all records and data under the remaining ID. To date, when this has occurred, we’ve informed providers of changes via CSVs
* they can check if a participant’s ID has changed using the `participant_id_changes` nested structure in the [ECFEnrolment](/api-reference/reference-v3.html#schema-ecfenrolment), which contains a `from_participant_id` and a `to_participant_id` string fields, as well a `changed_at` date value
* if they cannot see a mentor as expected using this endpoint, it's probably because the mentor is not eligible for funding through them. In this case, providers should use the [GET /api/v3/unfunded-mentors/ecf/{id} endpoint](/api-reference/reference-v3.html#api-v3-unfunded-mentors-ecf-id-get) to retrieve the mentor’s details

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
      "updated_at": "2024-05-31T02:22:32.000Z",
      "ecf_enrolments": [
        {
          "training_record_id": "000a97ff-d2a9-4779-a397-9bfd9063072e",
          "email": "jane.smith@some-school.example.com",
          "mentor_id": "bb36d74a-68a7-47b6-86b6-1fd0d141c590",
          "school_urn": "106286",
          "participant_type": "ect",
          "cohort": "2024",
          "training_status": "active",
          "participant_status": "active",
          "teacher_reference_number_validated": true,
          "eligible_for_funding": true,
          "pupil_premium_uplift": true,
          "sparsity_uplift": true,
          "schedule_identifier": "ecf-standard-january",
          "delivery_partner_id": "cd3a12347-7308-4879-942a-c4a70ced400a",
          "withdrawal": null,
          "deferral": null,
          "created_at": "2024-05-31T02:22:32.000Z",
          "induction_end_date": "2025-01-12",
          "mentor_funding_end_date": "2024-04-19",
          "cohort_changed_after_payments_frozen": false
        }
      ],
      "participant_id_changes": [
        {
          "from_participant_id": "23dd8d66-e11f-4139-9001-86b4f9abcb02",
          "to_participant_id": "db3a7848-7308-4879-942a-c4a70ced400a",
          "changed_at": "2023-09-23T02:22:32.000Z",
        }
      ]
    }
  }
}
```

### Retrieve multiple unfunded mentors 

``` 
GET /api/v3/unfunded-mentors/ecf 
```  

<div class="govuk-inset-text">Only available for systems integrated with API v3 onwards. It will not return data for API v1 or v2.</div> 
 
Lead providers can use this endpoint to retrieve the names and email addresses of all mentors who are not eligible for funding through them but are assigned to their ECTs. Typically, these mentors have either completed, or are currently doing, mentor training with a different lead provider than the one delivering training to the ECT they support.

For more detailed information, see the [‘Retrieve multiple unfunded mentors’ endpoint documentation](/api-reference/reference-v3.html#api-v3-unfunded-mentors-ecf-get). 

#### Example response body:

```
{
  "data": [
    {
      "id": "db3a7848-7308-4879-942a-c4a70ced400a",
      "type": "unfunded-mentor",
      "attributes": {
        "full_name": "Jane Smith",
        "email": "jane.smith@some-school.example.com",
        "teacher_reference_number": "1234567",
        "created_at": "2024-05-31T02:22:32.000Z",
        "updated_at": "2024-05-31T02:22:32.000Z"
      }
    }
  ]
}
```

### View details of a specific 'unfunded mentor'

```
 GET /api/v3/unfunded-mentors/ecf/{id}
```

<div class="govuk-inset-text">The following endpoint is only available for systems integrated with API v3 onwards. It will not return data for API v1 or v2.</div>

Lead providers can use this endpoint to retrieve the names and email addresses of individual mentors who are not eligible for funding through them but are assigned to their ECTs. Having these details will then enable providers to give these mentors access to the right learning platforms.

For more detailed information, [see the ‘Get a single unfunded mentor’ endpoint documentation](/api-reference/reference-v3.html#api-v3-unfunded-mentors-ecf-id-get).

#### Example response body:

```
{
  "data": {
    "id": "db3a7848-7308-4879-942a-c4a70ced400a",
    "type": "unfunded-mentor",
    "attributes": {
      "full_name": "Jane Smith",
      "email": "jane.smith@some-school.example.com",
      "teacher_reference_number": "1234567",
      "created_at": "2024-05-31T02:22:32.000Z",
      "updated_at": "2024-05-31T02:22:32.000Z"
    }
  }
}
```

### Notify DfE a participant has taken a break (deferred) from training

A participant can choose to take a break from ECF-based training at any time if they plan to resume training at a later date. Providers must notify DfE of this via the API.

```
 PUT /api/v{n}/participants/ecf/{id}/defer
```

An example request body is listed below.

Successful requests will return a response body including updates to the `training_status` attribute.

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

A participant can choose to resume their ECF-based training at any time if they had previously deferred. Providers must notify DfE of this via the API.

```
 PUT /api/v{n}/participants/ecf/{id}/resume
```

An example request body is listed below.

Successful requests will return a response body including updates to the `training_status` attribute.

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

A participant can choose to withdraw from ECF-based training at any time. Providers must notify DfE of this via the API.

```
 PUT /api/v{n}/participants/ecf/{id}/withdraw
```

An example request body is listed below.

Successful requests will return a response body including updates to the `training_status` attribute.

For more detailed information see the specifications for this [notify DfE that an ECF participant has withdrawn from training endpoint](/api-reference/reference-v3.html#api-v3-participants-ecf-id-withdraw-put).

#### Providers should note:

* DfE will **only** pay for participants who have had, at a minimum, a `started` declaration submitted against them
* DfE will pay providers for declarations submitted where the `declaration_date` is before the date of the withdrawal

Providers may see instances where a participant’s `training_status` and `participant_status` do not match. Providers are required to check the `participant_status` is accurate before notifying the DFE that the participant has withdrawn from ECF-based training with them altogether. **For example,** a participant has `"training_status": "active"` while their `"participant_status": "withdrawn"`. This would indicate an induction tutor has entered the DfE service to inform DfE that the participant has withdrawn from training at their school. However, the provider in partnership with that school has not yet withdrawn the participant via the API.  The participant’s `training_status` will remain `active` until the provider investigates (to see if the participant has withdrawn or has transferred to a new school) and notifies DfE a participant has withdrawn from training (`"training_status": "withdrawn"`).

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

### Notify DfE of a participant's training schedule

<div class="govuk-inset-text">All participants will be registered by default to a standard schedule starting in September. Providers must notify the DfE of any other schedule.</div>

Participants can choose to follow standard or non-standard training schedules.

```
 PUT /api/v3/participants/ecf/{id}/change-schedule
```

An example request body is listed below.

Successful requests will return a response body including updates to the `schedule_identifier` attribute.

#### Providers should note:

Milestone validation applies. The API will reject a schedule change if any previously submitted `eligible`, `payable` or `paid` declarations have a `declaration_date` which does not align with the new schedule’s milestone dates.

Where this occurs, providers should:

1. void the existing declarations (where declaration_date does not align with the new schedule)
2. change the participant’s training schedule
3. resubmit backdated declarations (where declaration_date aligns with the new schedule)

For replacement mentors, view [guidance on updating a replacement mentor’s schedule.](/api-reference/ecf/guidance.html#update-a-replacement-mentor-s-schedule)

For more detailed information see the specifications for this [notify that an ECF participant has changed their training schedule endpoint](/api-reference/reference-v3.html#api-v3-participants-ecf-id-change-schedule-put).

#### Example request body:

```
{
  "data": {
    "type": "participant-change-schedule",
    "attributes": {
      "schedule_identifier": "ecf-standard-january",
      "course_identifier": "ecf-mentor",
      "cohort": "2024"
    }
  }
}
```

###  Update a replacement mentor’s schedule

A new mentor can be assigned to an ECT part way through training, replacing the ECT’s original mentor.

[Providers must notify the DfE of replacement mentors by updating their training schedule.](/api-reference/ecf/guidance.html#notify-dfe-of-a-participant-39-s-training-schedule)

Note, if a replacement mentor is already mentoring another ECT and they replace a mentor for a second ECT, the first ECT takes precedence. In this instance, the provider should not change the mentor’s schedule.

Providers must include a `schedule_identifier` reflecting when the replacement mentor starts.

* `ecf-replacement-september`
* `ecf-replacement-january`
* `ecf-replacement-april`

For API v3 onwards, a replacement mentor's schedule, and any associated declaration submissions, do not need to align with the ECT they are mentoring.

Previously for API v1 and v2, a replacement mentor could start mentoring an ECT part way through their training. The provider had already submitted a `start` declaration for the previous mentor (in line with the ECT). If the provider were to submit a `retention-1` declaration for the ECT, then any declaration submitted for the new replacement mentor in the same milestone period would also have to be a retention-1 declaration. This is no longer the case for API v3.

## Participant transfers (v3 API-only) 
 
In the v3 API, lead providers can: 
 
* view transfer data as soon as schools report a move
* see participant status updates based on reported joining and leaving dates
* identify whether a participant is `joining`, `leaving`, `left`, or `active` depending on timing
* retrieve details of transferred ECTs and mentors to maintain accurate records 

Lead providers should update training statuses when a participant withdraws from their programme to ensure data accuracy. 

### View data for all participants who have transferred 

``` 
GET /api/v3/participants/ecf/transfers 
``` 

Lead providers can use this endpoint to view data for participants who’ve transferred from and to schools they’re in partnership with. The data is updated whenever schools report a transfer. 

View the [‘Retrieve multiple ECF participant transfers’ endpoint documentation](/api-reference/reference-v3.html#api-v3-participants-ecf-transfers-get). 

### View data for a specific participant who has transferred  

``` 
GET /api/v3/participants/ecf/{id}/transfers 
``` 

Lead providers can use this endpoint to view data for individual participants who’ve transferred from and to schools they’re in partnership with.  

View the [‘Get a single participant’s transfers’ endpoint documentation](/api-reference/reference-v3.html#api-v3-participants-ecf-id-transfers-get).

### What providers will see in the API when a participant is transferring away from them  
| Scenario | Participant status | Transfer response |
| -------- | -----------------  | ----------------- |
| **Before transfer** | Active      | N/A |
| **Old school induction tutor reports leaver** | Leaving | Shows leaving details |
| **New school induction tutor reports joiner** | Leaving | Shows leaving and joining details |
| **After transfer** | Left | Shows leaving and joining details |

### What providers will see in the API when a participant is transferring to them
| Scenario | Participant status | Transfer response |
| -------- | -----------------  | ----------------- |
| **New school induction tutor reports joiner** | Joining | Shows leaving and joining details |
| **After transfer** | Active | Shows leaving and joining details |

### What providers will see in the API if a participant is staying with them after transferring schools 
| Scenario | Participant status | Transfer response |
| -------- | -----------------  | ----------------- |
| **Before transfer** | Active | N/A |
| **Old school induction tutor reports leaver** | Leaving | Shows leaving details |
| **New school induction tutor reports joiner** | Joining (new school details shown) | Shows leaving and joining details |
| **After transfer** | Active | Shows leaving and joining details |

### Managing transfers between providers 
 
Providers must [notify DfE when a participant withdraws](/api-reference/reference-v3.html#api-v3-participants-ecf-id-withdraw-put) from their training to ensure data accuracy. Once a participant transfers to a new provider and school induction tutors have confirmed the move, the original provider will see the `participant_status` as `left`. They should then update the participant’s `training_status` to `withdrawn`. The transfer record will also appear in `GET transfers` and `GET {id}/transfers` endpoint responses.

### Why transfer data can appear incomplete 
 
There can sometimes be a transfer data 'lag' because induction tutors enter information at different times. For example, if a participant is leaving one school but their new school hasn’t confirmed the transfer yet, only data from the departing school will be available via the API.  

### How transfer dates between schools affect a participant’s status 

A participant's joining and leaving dates are determined by when the outbound school reports them as leaving and the inbound school reports them as joining. This affects how their `status` appears for lead providers. 
 
When a new school's induction tutor reports a participant joining before the previous school confirms their departure, the `leaving_date` remains `null` until the old school updates it. 

### What to look for in the response bodies of transfer endpoints   

Successful requests will return details including: 

* participant IDs
* the name of the provider a participant is transferring to or from
* the unique reference number (URN) of the school a participant is transferring to or from
* the type of transfer. For example, `new_school` or `new_provider`
* a `status` field to show whether the transfer has already taken place or is in progress

#### Example response body:

```
{
  "data": [
    {
      "id": "db3a7848-7308-4879-942a-c4a70ced400a",
      "type": "participant-transfer",
      "attributes": {
        "updated_at": "2024-05-31T02:22:32.000Z",
        "transfers": [
          {
            "training_record_id": "000a97ff-d2a9-4779-a397-9bfd9063072e",
            "transfer_type": "new_provider",
            "status": "complete",
            "leaving": {
              "school_urn": "123456",
              "provider": "Old Institute",
              "date": "2024-05-31"
            },
            "joining": {
              "school_urn": "654321",
              "provider": "New Institute",
              "date": "2024-06-01"
            },
            "created_at": "2024-05-31T02:22:32.000Z"
          }
        ]
      }
    }
  ]
}
```

## Submit, view and void declarations

Providers must submit declarations in line with ECF contractual [schedules and milestone dates](/api-reference/ecf/schedules-and-milestone-dates).

These declarations will trigger payment from DfE to providers.

When providers submit declarations, API response bodies will include data about which financial statement the given declaration applies to. Providers can then [view financial statement payment dates](/api-reference/ecf/guidance/#view-financial-statement-payment-dates) to check when the invoicing period, and expected payment date, will be for the given declaration.

<div class="govuk-inset-text">DfE will close the funding contract for the 2021 cohort on 31 July 2024. School will start moving ECTs and mentors with partial declarations originally assigned to the 2021 cohort to the 2024 cohort from mid-June. Providers will not be able to submit or void declarations for 2021 after the contract has closed.</div>

### Test the ability to submit declarations in sandbox ahead of time

`X-With-Server-Date` is a custom JSON header supported in the sandbox environment. It lets providers test their integrations and ensure they are able to submit declarations for future milestone dates.

The `X-With-Server-Date` header lets providers simulate future dates, and therefore allows providers to test declaration submissions for future milestone dates.

<div class="govuk-inset-text">It's only valid in the sandbox environment. Attempts to submit future declarations in the production environment (or without this header in sandbox) will be rejected as part of milestone validation.</div>

To test declaration submission functionality, include:

* the header `X-With-Server-Date` as part of declaration submission request
* the value of your chosen date in ISO8601 Date with time and Timezone (i.e. RFC3339 format). For example:

```
X-With-Server-Date: 2025-01-10T10:42:00Z
```

### Submit a declaration to notify DfE a participant has started training

Notify the DfE that a participant has started ECF-based training by submitting a `started` declaration in line with [milestone 1 dates](/api-reference/ecf/schedules-and-milestone-dates).

```
 POST /api/v3/participant-declarations
```

An example request body is listed below. Request bodies must include the necessary data attributes, including the `declaration_type` attribute with a `started` value.

An example response body is listed below. Successful requests will return a response body with declaration data.

Any attempts to submit duplicate declarations will return an error message.

<div class="govuk-inset-text">Note, providers should store the returned ECF participant declaration ID for management tasks.</div>

For more detailed information see the specifications for this [notify DfE that an ECF participant has started training endpoint](/api-reference/reference-v3.html#api-v3-participant-declarations-post).

#### Example request body:

```
{
  "data": {
    "type": "participant-declaration",
    "attributes": {
      "participant_id": "db3a7848-7308-4879-942a-c4a70ced400a",
      "declaration_type": "started",
      "declaration_date": "2024-05-31T02:21:32.000Z",
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

### Submit a declaration to notify DfE a participant has been retained in training

Notify the DfE that a participant has reached a given retention point in their training by submitting a `retained` declaration in line with [milestone dates](/api-reference/ecf/schedules-and-milestone-dates).

```
POST /api/v{n}/participant-declarations
```

An example request body is listed below. Request bodies must include the necessary data attributes, including the appropriate `declaration_type` attribute value, for example `retained-1`.

An example response body is listed below. Successful requests will return a response body with declaration data.

Any attempts to submit duplicate declarations will return an error message.

<div class="govuk-inset-text">Note, providers should store the returned ECF participant declaration ID for management tasks.</div>

For more detailed information see the specifications for this [notify DfE that an ECF participant has been retained in training endpoint](/api-reference/reference-v3.html#api-v3-participant-declarations-post).

#### Example request body:

```
{
  “data”: {
    “type”: “participant-declaration”,
    “attributes”: {
      “participant_id”: “db3a7848-7308-4879-942a-c4a70ced400a”,
      “declaration_type”: “retained-1",
      “declaration_date”: “2024-05-31T02:21:32.000Z”,
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
      “declaration_date”: “2024-05-31T02:21:32.000Z”,
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

### Submit a declaration to notify DfE a participant has completed training

Notify the DfE that a participant has completed their training by submitting a `completed` declaration in line with [milestone dates](/api-reference/ecf/schedules-and-milestone-dates).

```
POST /api/v{n}/participant-declarations
```

An example request body is listed below. Request bodies must include the necessary data attributes, including the `declaration_type` attribute with a `completed` value.

An example response body is listed below. Successful requests will return a response body with declaration data.

Any attempts to submit duplicate declarations will return an error message.

<div class="govuk-inset-text">Note, providers should store the returned ECF participant declaration ID for future management tasks.</div>

For more detailed information see the specifications for this [notify DfE that an ECF participant has completed training endpoint](/api-reference/reference-v3.html#api-v3-participant-declarations-post).

#### Example request body:

```
{
  “data”: {
    “type”: “participant-declaration”,
    “attributes”: {
      “participant_id”: “db3a7848-7308-4879-942a-c4a70ced400a”,
      “declaration_type”: “completed”,
      “declaration_date”: “2024-05-31T02:21:32.000Z”,
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
      “declaration_date”: “2024-05-31T02:21:32.000Z”,
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

### View all previously submitted declarations

View all declarations which have been submitted to date. Check submissions, identify if any are missing, and void or clawback those which have been submitted in error.

```
GET /api/v3/participant-declarations
```

Note, providers can also filter results by adding filters to the parameter. For example: `GET /api/v3/participant-declarations?filter[participant_id]=ab3a7848-1208-7679-942a-b4a70eed400a` or `GET /api/v3/participant-declarations?filter[cohort]=2024&filter[updated_since]=2020-11-13T11:21:55Z`

An example response body is listed below.

For more detailed information see the specifications for this [view all declarations endpoint.](/api-reference/reference-v3.html#api-v3-participant-declarations-get)

#### Example response body:
```
{
  "data": [
    {
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
    },
    {
      "id": "db3a7848-7308-4879-942a-c4a70ced400a",
      "type": "participant-declaration",
      "attributes": {
        "participant_id": "08d78829-f864-417f-8a30-cb7655714e28",
        "declaration_type": "retained-1",
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
        "evidence_held": "training-event-attended"
      }
    }
  ]
}
```

### View a specific previously submitted declaration

View a specific declaration which has been previously submitted. Check declaration details and void or clawback those which have been submitted in error.

```
GET /api/v3/participant-declarations/{id}
```

An example response body is listed below.

For more detailed information see the specifications for this [view specific declarations endpoint.](/api-reference/reference-v3.html#api-v3-participant-declarations-id-get)

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

### Void or clawback a declaration

Void specific declarations which have been submitted in error.

```
PUT /api/v3/participant-declarations/{id}/void
```

An example response body is listed below. Successful requests will return a response body including updates to the declaration `state`, which will become:

* `voided` if it had been  `submitted`, `ineligible`, `eligible`, or `payable`
* `awaiting_clawback` if it had been `paid`

View more information on [declaration states.](/api-reference/ecf/definitions-and-states/#declaration-states)

For more detailed information see the specifications for this [void declarations endpoint.](/api-reference/reference-v3.html#api-v3-participant-declarations-id-void-put)

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
      "state": "voided",
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

## View financial statement payment dates

<div class="govuk-inset-text">The following endpoints are only available for systems integrated with API v3 onwards. They will not return data for API v1 or v2.</div>

Providers can view up to date payment cut-off dates, upcoming payment dates, and check to see whether output payments have been made by DfE.

### View all statement payment dates

```
GET /api/v3/statements
```

An example response body is listed below.

For more detailed information see the specifications for this [view all statements endpoint.](/api-reference/reference-v3.html#api-v3-statements-get)

#### Example response body:

```
{
  "data": [
    {
      "id": "cd3a12347-7308-4879-942a-c4a70ced400a",
      "type": "statement",
      "attributes": {
        "month": "May",
        "year": "2025",
        "type": "ecf",
        "cohort": "2024",
        "cut_off_date": "2025-04-30",
        "payment_date": "2025-05-25",
        "paid": true
        "created_at": "2024-05-31T02:22:32.000Z",
        "updated_at": "2024-05-31T02:22:32.000Z"
      }
    }
  ]
}
```

### View specific statement payment dates

```
GET /api/v3/statements/{id}
```

Providers can find statement IDs within [previously submitted declaration](/api-reference/ecf/guidance/#view-a-specific-previously-submitted-declaration) response bodies.

An example response body is listed below.

For more detailed information see the specifications for this [view a specific statement endpoint.](/api-reference/reference-v3.html#api-v3-statements-id-get)

#### Example response body:

```
{
  "data": {
    "id": "cd3a12347-7308-4879-942a-c4a70ced400a",
    "type": "statement",
    "attributes": {
      "month": "May",
      "year": "2025",
      "type": "ecf",
      "cohort": "2024",
      "cut_off_date": "2025-04-30",
      "payment_date": "2025-05-25",
      "paid": true,
      "created_at": "2024-05-31T02:22:32.000Z",
      "updated_at": "2024-05-31T02:22:32.000Z"
    }
  }
}
```
