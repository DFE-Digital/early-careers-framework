---
title: Guidance
weight: 2
---

# Guidance

The focus of the following guidance is on business logic only. Critical details which would be necessary for real-world usage have been left out. For example, [authentication](/api-reference/get-started/#connect-to-the-API) is not detailed.

<div class="govuk-inset-text">This guidance is written for API version 3.0.0, and therefore all endpoints reference `v3`. Providers should view specifications for the API version their systems are integrated as appropriate.</div>

## Overview of API requests
1. A person submits an application for an NPQ course via the DfE online service
2. Providers view NPQ application data via the API 
3. Providers complete their own suitability and application processes 
4. Providers accept or reject applications via the API and onboarding participants onto their systems
5. Providers train participants as per details set out in the contract
6. Providers submit `started` declarations via the API to notify DfE that participants have started their courses
7. DfE pays providers output payments for `started` declarations
8. Providers continue to train participants as per details set out in the contract
9. Providers submit `retained` declarations via the API to notify DfE participants have continued in training for a given milestone
10. DfE pays providers output payments for `retained` declarations
12. Providers complete training participants as per details set out in the contract
12. Providers will submit `completed` declarations via the API, including participant outcomes, to notify DfE participants have completed the course
13. DfE will pay providers output payments for `completed` declarations
14. Providers view financial statements via the API

Changes can happen during training; some participants may not complete their course within the standard schedule, or at all. Providers must update relevant data using the API. 

<div class="govuk-inset-text"> Note, DfE will only make payments for participants if providers have accepted course applications. Accepting applications is a separate request to submitting a ‘started’ declaration (which notifies DfE a participant has started training). </div>

## View, accept or reject NPQ applications

Providers can view application data to find out whether NPQ applicants:

* have a valid email address
* have a valid TRN
* are eligible for funding

Providers can then accept or reject applications to NPQ courses.

While people can make multiple applications for the same course, with one or multiple providers, **only** one provider can accept an application from a participant for an NPQ course. 

To prevent a participant being enrolled onto the same course with more than one provider the API will:

* **automatically update the `status` to `rejected` for all other applications:** If someone has made multiple applications with different providers (within a given cohort) and a provider accepts one, the API will update the `status` of all other applications with other providers to `rejected`
* **return an error message for new applications:** If a participant has had an application accepted by a provider, but then makes a new application for the same course with a new provider, the API will return an error message if the new provider tries to accept the new application

<div class="govuk-inset-text"> Providers must accept or reject applications before participants start a course and inform applicants of the outcome regardless of whether the application has been accepted or rejected. </div>

Note, while participants can enter different email addresses when applying for training courses, providers will only see the email address associated with a given course application or registration. For example, a participant may complete their ECF-based training with one associated email address, then apply for an NPQ with a different email address, and go on to be an ECT mentor with a third email address. The DfE will share the relevant email address with the relevant course provider.

$Accordion

$Heading
### View all applications
$EndHeading

$Content
```
 GET /api/v3/npq-applications
```

Note, providers can also filter results to see more specific or up to date data by adding `cohort`, `participant_id` and `updated_since` filters to the parameter. For example: `GET /api/v3/npq-applications?filter[cohort]=2021&filter[participant_id]=7e5bcdbf-c818-4961-8da5-439cab1984e0&filter[updated_since]=2020-11-13T11:21:55Z`

An example response body is listed below. 

For more detailed information see the specifications for this [view multiple NPQ applications endpoint](/api-reference/reference-v3.html#api-v3-npq-applications-get).

#### Example response body:

```


{
  "data": [
    {
      "id": "db3a7848-7308-4879-942a-c4a70ced400a",
      "type": "npq_application",
      "attributes": {
        "course_identifier": "npq-leading-teaching-development",
        "email": "isabelle.macdonald2@some-school.example.com",
        "email_validated": true,
        "employer_name": null,
        "employment_role": null,
        "full_name": "Isabelle MacDonald",
        "funding_choice": null,
        "headteacher_status": null,
        "ineligible_for_funding_reason": null,
        "participant_id": "53847955-7cfg-41eb-a322-96c50adc742b",
        "private_childcare_provider_urn": null,
        "teacher_reference_number": "0743795",
        "teacher_reference_number_validated": true,
        "school_urn": "123456",
        "school_ukprn": "12345678",
        "status": "pending",
        "works_in_school": true,
        "created_at": "2022-07-06T10:47:24Z",
        "updated_at": "2022-11-24T17:09:37Z",
        "cohort": "2022",
        "eligible_for_funding": true,
        "targeted_delivery_funding_eligibility": false,
        "teacher_catchment": true,
        "teacher_catchment_iso_country_code": "GBR",
        "teacher_catchment_country": "United Kingdom of Great Britain and Northern Ireland",
        "itt_provider": null,
        "lead_mentor": false
      }
    }
  ]
}
```
$EndContent

$Heading
### View a specific application
$EndHeading

$Content
```
 GET /api/v3/npq-applications/{id}
```

An example response body is listed below. 

For more detailed information see the specifications for this [view a specific NPQ application endpoint](/api-reference/reference-v3.html#api-v3-npq-applications-id-get).

#### Example response body:

```
{
  "data": {
    "id": "db3a7848-7308-4879-942a-c4a70ced400a",
    "type": "npq_application",
    "attributes": {
      "participant_id": "7a8fef46-3c43-42c0-b3d5-1ba5904ba562",
      "full_name": "Isabelle MacDonald",
      "email": "isabelle.macdonald2@some-school.example.com",
      "email_validated": true,
      "teacher_reference_number": "1234567",
      "teacher_reference_number_validated": true,
      "works_in_school": true,
      "employer_name": "Some Company Ltd",
      "employment_role": "Director",
      "school_urn": "106286",
      "private_childcare_provider_urn": "EY944860",
      "school_ukprn": "10079319",
      "headteacher_status": "no",
      "eligible_for_funding": true,
      "funding_choice": "trust",
      "course_identifier": "npq-leading-teaching",
      "status": "pending",
      "created_at": "2021-05-31T02:21:32.000Z",
      "updated_at": "2021-05-31T02:22:32.000Z",
      "ineligible_for_funding_reason": "establishment-ineligible",
      "cohort": "2022",
      "targeted_delivery_funding_eligibility": true,
      "teacher_catchment": true,
      "teacher_catchment_country": "France",
      "teacher_catchment_iso_country_code": "FRA",
      "lead_mentor": true,
      "itt_provider": "University of Southampton"
    }
  }
}
```
$EndContent

$Heading
### Accept an application 
$EndHeading

$Content
Providers should accept applications for those they want to enrol onto a course. Providers must inform applicants of the outcome of their successful NPQ application. 

Reasons to accept applications include (but are not limited to) the participant: 

* having funding confirmed
* being suitable for their chosen NPQ course
* having relevant support from their school

```
POST /api/v3/npq-applications/{id}/accept
```

The request parameter must include the `id` of the corresponding NPQ application. 

An example response body is listed below. Successful requests will return a response body including updates to the `status` attribute. 

<div class="govuk-inset-text"> Note, the API will prevent more than one provider accepting applications for the same course by automatically updating the application status or returning an error message. </div>

For more detailed information see the specifications for this [accept an NPQ application endpoint](/api-reference/reference-v3.html#api-v3-npq-applications-id-accept-post).

#### Example response body:

```
{
  "data": {
    "id": "db3a7848-7308-4879-942a-c4a70ced400a",
    "type": "npq_application",
    "attributes": {
      "participant_id": "7a8fef46-3c43-42c0-b3d5-1ba5904ba562",
      "full_name": "Isabelle MacDonald",
      "email": "isabelle.macdonald2@some-school.example.com",
      "email_validated": true,
      "teacher_reference_number": "1234567",
      "teacher_reference_number_validated": true,
      "works_in_school": true,
      "employer_name": "Some Company Ltd",
      "employment_role": "Director",
      "school_urn": "106286",
      "private_childcare_provider_urn": "EY944860",
      "school_ukprn": "10079319",
      "headteacher_status": "no",
      "eligible_for_funding": true,
      "funding_choice": "trust",
      "course_identifier": "npq-leading-teaching",
      "status": "accepted",
      "created_at": "2021-05-31T02:21:32.000Z",
      "updated_at": "2021-05-31T02:22:32.000Z",
      "ineligible_for_funding_reason": "establishment-ineligible",
      "cohort": "2022",
      "targeted_delivery_funding_eligibility": true,
      "teacher_catchment": true,
      "teacher_catchment_country": "France",
      "teacher_catchment_iso_country_code": "FRA",
      "lead_mentor": true,
      "itt_provider": "University of Southampton"
    }
  }
}
```
$EndContent

$Heading
### Reject an application
$EndHeading

$Content
Providers should reject applications for those they do not want to enrol onto a course. Providers must inform applicants of the outcome of their unsuccessful NPQ application.

Reasons to reject applications include (but are not limited to) the participant: 

* having been unsuccessful in their application process
* not having secured funding
* wanting to use another provider
* wanting to take on another course
* no longer wants to take the course 

```
POST /api/v3/npq-applications/{id}/reject
```
The request parameter must include the `id` of the corresponding NPQ application. 

An example response body is listed below. Successful requests will return a response body including updates to the `status` attribute. 

For more detailed information see the specifications for this [accept an NPQ application endpoint](/api-reference/reference-v3.html#api-v3-npq-applications-id-reject-post).

#### Example response body:

```
{
  "data": {
    "id": "db3a7848-7308-4879-942a-c4a70ced400a",
    "type": "npq_application",
    "attributes": {
      "participant_id": "7a8fef46-3c43-42c0-b3d5-1ba5904ba562",
      "full_name": "Isabelle MacDonald",
      "email": "isabelle.macdonald2@some-school.example.com",
      "email_validated": true,
      "teacher_reference_number": "1234567",
      "teacher_reference_number_validated": true,
      "works_in_school": true,
      "employer_name": "Some Company Ltd",
      "employment_role": "Director",
      "school_urn": "106286",
      "private_childcare_provider_urn": "EY944860",
      "school_ukprn": "10079319",
      "headteacher_status": "no",
      "eligible_for_funding": true,
      "funding_choice": "trust",
      "course_identifier": "npq-leading-teaching",
      "status": "rejected",
      "created_at": "2021-05-31T02:21:32.000Z",
      "updated_at": "2021-05-31T02:22:32.000Z",
      "ineligible_for_funding_reason": "establishment-ineligible",
      "cohort": "2022",
      "targeted_delivery_funding_eligibility": true,
      "teacher_catchment": true,
      "teacher_catchment_country": "France",
      "teacher_catchment_iso_country_code": "FRA",
      "lead_mentor": true,
      "itt_provider": "University of Southampton"
    }
  }
}
```
$EndContent

$Heading
### Update an application due to a change in circumstance
$EndHeading

$Content
There are several reasons why there might be a change in circumstance for an NPQ application, including where a participant:

* made a mistake during their application
* selected the incorrect course during their application
* now wants to take another course instead
* now wants to fund their NPQ differently

Where there has been a change in circumstance, providers should:

* reject the application if the application `status` is `pending`
* contact the DfE if the application `status` is `accepted` 

For example, if a participant registers for an NPQ course but then decides to change to another course, the provider should: 

1. reject that participant’s application
2. ask the participant to re-register on the NPQ registration service, entering the correct NPQ course details
3. accept the new application once it is available via the API
$EndContent

$EndAccordion

## View and update participant data

Once a provider has accepted an application, they can view and update data to notify DfE that a participant has: 

* [deferred their course](/api-reference/npq/guidance/#notify-dfe-a-participant-has-taken-a-break-deferred-from-training)
* [resumed their course](/api-reference/npq/guidance/#notify-dfe-a-participant-has-resumed-training)
* [withdrawn from their course](/api-reference/npq/guidance/#notify-dfe-a-participant-has-withdrawn-from-training)
* [changed their course schedule](/api-reference/npq/guidance/#notify-dfe-a-participant-has-changed-their-training-schedule)
* [an updated course outcome](/api-reference/npq/guidance.html#update-a-participant-s-outcomes)

$Accordion

$Heading
### View all participant data
$EndHeading

$Content
```
GET /api/v3/participants/npq
```

Note, providers can also filter results by adding `updated_since` filters to the parameter. For example: `GET /api/v{n}/participants/ecf?filter[updated_since]=2020-11-13T11:21:55Z`

An example response body is listed below. 

For more detailed information see the specifications for this [view multiple NPQ participants endpoint](/api-reference/reference-v3.html#api-v3-participants-npq-get).

#### Example response body:

```
{
  "data": [
    {
      "id": "ac3d1243-7308-4879-942a-c4a70ced400a",
      "type": "npq-participant",
      "attributes": {
        "full_name": "Isabelle MacDonald",
        "teacher_reference_number": "1234567",
        "updated_at": "2021-05-31T02:22:32.000Z",
        "npq_enrolments": [
          {
            "email": "isabelle.macdonald2@some-school.example.com",
            "course_identifier": "npq-senior-leadership",
            "schedule_identifier": "npq-leadership-autumn",
            "cohort": "2021",
            "npq_application_id": "db3a7848-7308-4879-942a-c4a70ced400a",
            "eligible_for_funding": true,
            "training_status": "active",
            "school_urn": "123456",
            "targeted_delivery_funding_eligibility": true,
            "withdrawal": null
            "deferral": null
            "created_at": "2021-05-31T02:22:32.000Z"
          }
        ]
      }
    }
  ]
}
```
$EndContent

$Heading
### View a single participant’s data
$EndHeading

$Content
```
 GET /api/v3/participants/npq/{id}
```

An example response body is listed below. 

For more detailed information see the specifications for this [view a single NPQ participant endpoint](/api-reference/reference-v3.html#api-v3-participants-npq-id-get).


#### Example response body:


```
{
  "data": [
    {
      "id": "ac3d1243-7308-4879-942a-c4a70ced400a",
      "type": "npq-participant",
      "attributes": {
        "full_name": "Isabelle MacDonald",
        "teacher_reference_number": "1234567",
        "updated_at": "2021-05-31T02:22:32.000Z",
        "npq_enrolments": [
          {
            "email": "isabelle.macdonald2@some-school.example.com",
            "course_identifier": "npq-senior-leadership",
            "schedule_identifier": "npq-leadership-autumn",
            "cohort": "2021",
            "npq_application_id": "db3a7848-7308-4879-942a-c4a70ced400a",
            "eligible_for_funding": true,
            "training_status": "active",
            "school_urn": "123456",
            "targeted_delivery_funding_eligibility": true,
            "withdrawal": null
            "deferral": null
            "created_at": "2021-05-31T02:22:32.000Z"
          }
        ]
      }
    }
  ]
}
```
$EndContent

$Heading
### Notify DfE a participant has taken a break (deferred) from training
$EndHeading

$Content
A participant can choose to take a break from their NPQ course at any time if they plan to resume training at a later date. Providers must notify DfE of this via the API.

```
 PUT /api/v{n}/participants/npq/{id}/defer
```

An example request body is listed below. 

Successful requests will return a response body including updates to the `training_status` attribute.

For more detailed information see the specifications for this [notify DfE that an NPQ participant is taking a break from their course endpoint](/api-reference/reference-v3.html#api-v3-participants-npq-id-defer-put).

#### Example request body:

```
{
  "data": {
    "type": "participant-defer",
    "attributes": {
      "reason": "parental-leave",
      "course_identifier": "npq-senior-leadership"
    }
  }
}
```
$EndContent

$Heading
### Notify DfE a participant has resumed training
$EndHeading

$Content
A participant can choose to resume their NPQ course at any time if they had previously deferred. Providers must notify DfE of this via the API.

```
 PUT /api/v3/participants/npq/{id}/resume
```

An example request body is listed below. 

Successful requests will return a response body including updates to the `training_status` attribute.

For more detailed information see the specifications for this [notify DfE that an NPQ participant has resumed training endpoint](/api-reference/reference-v3.html#api-v3-participants-npq-id-resume-put).

#### Example request body:

```
{
  "data": {
    "type": "participant-resume",
    "attributes": {
      "course_identifier": "npq-leading-teaching-development"
    }
  }
}
```
$EndContent

$Heading
###  Notify DfE a participant has withdrawn from training
$EndHeading

$Content
A participant can choose to withdraw from an NPQ course at any time. Providers must notify DfE of this via the API.

```
 PUT /api/v3/participants/npq/{id}/withdraw
```

An example request body is listed below. 

Successful requests will return a response body including updates to the `training_status` attribute.

#### Providers should note: 

* The API will **not** allow withdrawals for participants who have not had a `started` declaration submitted against them. If a participant withdraws before a `started` declaration has been submitted, providers should inform their contract manager who can advise
* DfE will **only** pay for participants who have had, at a minimum, a `started` declaration submitted against them
* If a participant is withdrawn later in their course, DfE will pay providers for any declarations submitted where the `declaration_date` is before the date of the withdrawal
* The amount DfE will pay depends on which milestones have been reached with declarations submitted before withdrawal

For more detailed information see the specifications for this [notify DfE that an NPQ participant has withdrawn from training endpoint](/api-reference/reference-v3.html#api-v3-participants-npq-id-withdraw-put).

#### Example request body:

```
{
  "data": {
    "type": "participant-withdraw",
    "attributes": {
      "reason": "quality-of-programme-other",
      "course_identifier": "npq-leading-teaching-development"
    }
  }
}
```
$EndContent

$Heading
### Notify DfE a participant has changed their training schedule
$EndHeading

$Content
The API will automatically assign schedules to participants depending on when course applications are accepted by providers. Providers must notify the DfE of any schedule change.

```
 PUT /api/v3/participants/npq/{id}/change-schedule
```

An example request body is listed below. 

Successful requests will return a response body including updates to the `schedule_identifier` attribute.

**Note**, the API will reject a schedule change if any `submitted`, `eligible`, `payable` or `paid` declarations have a `declaration_date` which does not align with the new schedule’s milestone dates. 

For example, a participant is in the 2022 cohort on an `npq-specialist-autumn` schedule. Their provider has submitted a `started` declaration dated 1 October 2022. The provider tries to change the schedule to `npq-specialist-spring`. The API will reject the change because a spring schedule does not start until January, which is after the declaration date. The API returns an error message with instructions to void existing declarations first.

For more detailed information see the specifications for this [notify that an NPQ participant has changed their training schedule endpoint](/api-reference/reference-v3.html#api-v3-participants-npq-id-change-schedule-put).

#### Example request body:

```
{
  "data": {
    "type": "participant-change-schedule",
    "attributes": {
      "schedule_identifier": "npq-leadership-autumn",
      "course_identifier": "npq-leading-teaching",
      "cohort": "2021"
    }
  }
}
```
$EndContent

$Heading
### View all participant outcomes
$EndHeading

$Content
Participants can either pass or fail assessment at the end of their NPQ course. These outcomes are submitted by providers within `completed` declaration submissions.

**Note**, outcomes are sent to the Database of Qualified Teachers (DQT) who issue certificates to participants who have passed.

```
 GET /api/v3/participants/npq/outcomes
```

An example response body is listed below. Successful requests will return a response body including an outcome `state` value to signify:

* outcomes submitted (`passed` or `failed`)
* if `completed` declarations have been voided and the outcome retracted (`voided`)

For more detailed information see the specifications for this [view NPQ outcomes endpoint](/api-reference/reference-v3.html#api-v3-participants-npq-outcomes-get).

#### Example response body:

```
{
  "data": [
    {
      "id": "cd3a12347-7308-4879-942a-c4a70ced400a",
      "type": "participant-outcome",
      "attributes": {
        "participant_id": "66218835-9430-4d0c-98ef-7caf0bb4a59b",
        "course_identifier": "npq-leading-teaching",
        "state": "passed",
        "completion_date": "2021-05-31",
        "created_at": "2021-05-31T02:21:32.000Z"
      }
    }
  ]
}
```
$EndContent

$Heading
### View a specific participant’s outcome
$EndHeading

$Content
A participant can either pass or fail assessment at the end of their NPQ course. Their outcome will be submitted by providers within `completed` declaration submissions.

**Note**, outcomes are sent to the Database of Qualified Teachers (DQT) who issue certificates to participants who have passed.

```
 GET /api/v3/participants/npq/{participant_id}/outcomes
```

An example response body is listed below. Successful requests will return a response body including an outcome `state` value to signify:

* the outcome submitted (`passed` or `failed`)
* if the `completed` declaration has been voided and the outcome retracted (`voided`)

For more detailed information see the specifications for this [view NPQ outcome for a specific participant endpoint](/api-reference/reference-v3.html#api-v3-participants-npq-participant_id-outcomes-get).

#### Example response body:

```
{
  "data": [
    {
      "id": "cd3a12347-7308-4879-942a-c4a70ced400a",
      "type": "participant-outcome",
      "attributes": {
        "participant_id": "66218835-9430-4d0c-98ef-7caf0bb4a59b",
        "course_identifier": "npq-leading-teaching",
        "state": "passed",
        "completion_date": "2021-05-31",
        "created_at": "2021-05-31T02:21:32.000Z"
      }
    }
  ]
}
```
$EndContent

$Heading
### Update a participant’s outcomes
$EndHeading

$Content
Outcomes may need to be updated if previously submitted data was inaccurate. For example, a provider should update a participant’s outcome if:

* the reported outcome was incorrect
* the reported date the participant received their outcome was incorrect
* a participant has retaken their NPQ assessment and their outcome has changed

```
POST /api/v1/participant/npq/{participant_id}/outcomes
```

An example request body is listed below. Request bodies must include a new value for the outcome `state` and `completion_date`. 

Successful requests will return a response body with updates included. 

For more detailed information see the specifications for this [update an NPQ outcome endpoint](/api-reference/reference-v3.html#api-v3-participants-npq-participant_id-outcomes-post).

#### Example request body: 

```
{
  "data": {
    "type": "npq-outcome-confirmation",
    "attributes": {
      "course_identifier": "npq-leading-teaching",
      "state": "passed",
      "completion_date": "2021-05-31"
    }
  }
}
```
$EndContent

$EndAccordion

## Submit, view and void declarations

Providers must submit declarations in line with NPQ contractual [schedules and milestone dates](/api-reference/npq/schedules-and-milestone-dates). 

These declarations will trigger payment from DfE to providers. 

When providers submit declarations, API response bodies will include data about which financial statement the given declaration applies to. Providers can then [view financial statement payment dates](/api-reference/npq/guidance/#view-financial-statement-payment-dates) to check when the invoicing period, and expected payment date, will be for the given declaration.

$Accordion

$Heading
### Test the ability to submit declarations in sandbox ahead of time 
$EndHeading

$Content
`X-With-Server-Date` is a custom JSON header supported in the sandbox environment. It lets providers test their integrations and ensure they are able to submit declarations for future milestone dates.

The `X-With-Server-Date` header lets providers simulate future dates, and therefore allows providers to test declaration submissions for future milestone dates. 

<div class="govuk-inset-text">It is only valid in the sandbox environment. Attempts to submit future declarations in the production environment (or without this header in sandbox) will be rejected as part of milestone validation.</div>

To test declaration submission functionality, include: 

* the header `X-With-Server-Date` as part of declaration submission request
* the value of your chosen date in ISO8601 Date with time and Timezone (i.e. RFC3339 format). For example: 

```
X-With-Server-Date: 2022-01-10T10:42:00Z
```
$EndContent

$Heading
### Notify DfE a participant has started training
$EndHeading

$Content
Notify the DfE that a participant has started an NPQ course by submitting a `started` declaration in line with [milestone 1 dates](/api-reference/npq/schedules-and-milestone-dates).

```
 POST /api/v3/participant-declarations
```

An example request body is listed below. Request bodies must include the necessary data attributes, including the `declaration_type` attribute with a `started` value. 

An example response body is listed below. Successful requests will return a response body with declaration data. 

Any attempts to submit duplicate declarations will return an error message.

<div class="govuk-inset-text">Note, providers should store the returned NPQ participant declaration ID for management tasks.</div>

For more detailed information see the specifications for this [notify DfE that an NPQ participant has started training endpoint](/api-reference/reference-v3.html#api-v3-participant-declarations-post).

#### Example request body:

```
{
  "data": {
    "type": "participant-declaration",
    "attributes": {
      "participant_id": "db3a7848-7308-4879-942a-c4a70ced400a",
      "declaration_type": "started",
      "declaration_date": "2021-05-31T02:21:32.000Z",
      "course_identifier": "npq-leading-teaching"
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
      "participant_id": "bf3c6251-f2a0-4690-a859-0fbecc6ed151",
      "declaration_type": "started",
      "declaration_date": "2020-11-13T11:21:55Z",
      "course_identifier": "npq-leading-teaching",
      "state": "eligible",
      "updated_at": "2020-11-13T11:21:55Z",
      "created_at": "2020-11-13T11:21:55Z",
      "delivery_partner_id": null,
      "statement_id": "1cceffd7-0efd-432a-aedc-7be2d6cc72a2",
      "clawback_statement_id": null,
      "ineligible_for_funding_reason": null,
      "mentor_id": null,
      "uplift_paid": true,
      "evidence_held": null
      "has_passed": null
    }
  }
}
```
$EndContent

$Heading
### Notify DfE a participant has been retained in training
$EndHeading

$Content
Notify the DfE that a participant has reached a given retention point in their course by submitting a `retained` declaration in line with [milestone dates](/api-reference/npq/schedules-and-milestone-dates).

```
POST /api/v{n}/participant-declarations
```

An example request body is listed below. Request bodies must include the necessary data attributes, including the appropriate `declaration_type` attribute value, for example `retained-1`. 

An example response body is listed below. Successful requests will return a response body with declaration data. 

Any attempts to submit duplicate declarations will return an error message.

<div class="govuk-inset-text">Note, providers should store the returned NPQ participant declaration ID for management tasks.</div>

For more detailed information see the specifications for this [notify DfE that an NPQ participant has been retained in training endpoint](/api-reference/reference-v3.html#api-v3-participant-declarations-post).

#### Example request body:

```
{
  “data”: {
    “type”: “participant-declaration”,
    “attributes”: {
      "participant_id": "db3a7848-7308-4879-942a-c4a70ced400a",
      "declaration_type": "retained-1",
      "declaration_date": "2021-05-31T02:21:32.000Z",
      "course_identifier": "npq-headship"
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
      "participant_id": "bf3c6251-f2a0-4690-a859-0fbecc6ed151",
      "declaration_type": "retained-1",
      "declaration_date": "2020-11-13T11:21:55Z",
      "course_identifier": "npq-headship",
      "state": "eligible",
      "updated_at": "2020-11-13T11:21:55Z",
      "created_at": "2020-11-13T11:21:55Z",
      "delivery_partner_id": null,
      "statement_id": "1cceffd7-0efd-432a-aedc-7be2d6cc72a2",
      "clawback_statement_id": null,
      "ineligible_for_funding_reason": null,
      "mentor_id": null,
      "uplift_paid": true,
      "evidence_held": null
      "has_passed": null
    }
  }
}
```
$EndContent

$Heading
### Notify DfE a participant has completed training
$EndHeading

$Content
Notify the DfE that a participant has completed their course by submitting a `completed` declaration in line with [milestone dates](/api-reference/npq/schedules-and-milestone-dates).

```
POST /api/v{n}/participant-declarations
```

An example request body is listed below. Request bodies must include the necessary data attributes, including the `declaration_type` attribute with a `completed` value, and the`has_passed` attribute with a `true` or `false` value.

An example response body is listed below. Successful requests will return a response body with declaration data. 

**Note**, any attempts to submit duplicate declarations will return an error message.

<div class="govuk-inset-text">Providers should store the returned NPQ participant declaration ID for future management tasks.</div>

For more detailed information see the specifications for this [notify DfE that an NPQ participant has completed training endpoint](/api-reference/reference-v3.html#api-v3-participant-declarations-post).

#### Example request body:

```
{
  “data”: {
    “type”: “participant-declaration”,
    “attributes”: {
      "participant_id": "db3a7848-7308-4879-942a-c4a70ced400a",
      "declaration_type": "completed",
      "declaration_date": "2021-05-31T02:21:32.000Z",
      "course_identifier": "npq-leading-teaching",
      "has_passed": true
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
      "participant_id": "db3a7848-7308-4879-942a-c4a70ced400a",
      "declaration_type": "completed",
      "declaration_date": "2021-05-31T02:21:32.000Z",
      "course_identifier": "npq-leading-teaching",
      "state": "eligible",
      "updated_at": "2020-11-13T11:21:55Z",
      "created_at": "2020-11-13T11:21:55Z",
      "delivery_partner_id": null,
      "statement_id": "1cceffd7-0efd-432a-aedc-7be2d6cc72a2",
      "clawback_statement_id": null,
      "ineligible_for_funding_reason": null,
      "mentor_id": null,
      "uplift_paid": true,
      "evidence_held": null
      "has_passed": true
    }
  }
}
```
$EndContent

$Heading
### View all previously submitted declarations 
$EndHeading

$Content
View all declarations which have been submitted to date. Check declaration submissions, identify if any are missing, and void or clawback those which have been submitted in error.

```
GET /api/v3/participant-declarations
```

Note, providers can also filter results by adding filters to the parameter. For example: `GET /api/v3/participant-declarations?filter[participant_id]=ab3a7848-1208-7679-942a-b4a70eed400a` or `GET /api/v3/participant-declarations?filter[cohort]=2022&filter[updated_since]=2020-11-13T11:21:55Z`

An example response body is listed below. 

For more detailed information see the specifications for this [view all declarations endpoint.](/api-reference/reference-v3.html#api-v3-participant-declarations-get)

#### Example response body:

```
{
  "data": {
    "id": "db3a7848-7308-4879-942a-c4a70ced400a",
    "type": "participant-declaration",
    "attributes": {
      "participant_id": "bf3c6251-f2a0-4690-a859-0fbecc6ed151",
      "declaration_type": "started",
      "declaration_date": "2020-11-13T11:21:55Z",
      "course_identifier": "npq-leading-teaching",
      "state": "eligible",
      "updated_at": "2020-11-13T11:21:55Z",
      "created_at": "2020-11-13T11:21:55Z",
      "delivery_partner_id": null,
      "statement_id": "1cceffd7-0efd-432a-aedc-7be2d6cc72a2",
      "clawback_statement_id": null,
      "ineligible_for_funding_reason": null,
      "mentor_id": null,
      "uplift_paid": true,
      "evidence_held": null
      "has_passed": null
    }
  }
}
```
$EndContent

$Heading
### View a specific previously submitted declaration
$EndHeading

$Content
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
      "participant_id": "bf3c6251-f2a0-4690-a859-0fbecc6ed151",
      "declaration_type": "started",
      "declaration_date": "2020-11-13T11:21:55Z",
      "course_identifier": "npq-leading-teaching",
      "state": "eligible",
      "updated_at": "2020-11-13T11:21:55Z",
      "created_at": "2020-11-13T11:21:55Z",
      "delivery_partner_id": null,
      "statement_id": "1cceffd7-0efd-432a-aedc-7be2d6cc72a2",
      "clawback_statement_id": null,
      "ineligible_for_funding_reason": null,
      "mentor_id": null,
      "uplift_paid": true,
      "evidence_held": null
      "has_passed": null
    }
  }
}
```
$EndContent

$Heading
### Void or clawback a declaration
$EndHeading

$Content
Void specific declarations which have been submitted in error. 

```
PUT /api/v3/participant-declarations/{id}/void
```

An example response body is listed below. Successful requests will return a response body including updates to the declaration `state`, which will become: 

* `voided` if it had been  `submitted`, `ineligible`, `eligible`, or `payable`
* `awaiting_clawback` if it had been `paid` 

View more information on [declaration states.](/api-reference/npq/definitions-and-states/#declaration-states) 

Note, if a provider voids a `completed` declaration, the outcome (indicating whether they have passed or failed) will be retracted. The `has_passed` value will revert to `null`.

For more detailed information see the specifications for this [void declarations endpoint.](/api-reference/reference-v3.html#api-v3-participant-declarations-id-void-put)

#### Example response body:

```
{
  "data": {
    "id": "db3a7848-7308-4879-942a-c4a70ced400a",
    "type": "participant-declaration",
    "attributes": {
      "participant_id": "bf3c6251-f2a0-4690-a859-0fbecc6ed151",
      "declaration_type": "completed",
      "declaration_date": "2020-11-13T11:21:55Z",
      "course_identifier": "npq-leading-teaching",
      "state": "voided",
      "updated_at": "2020-11-13T11:21:55Z",
      "created_at": "2020-11-13T11:21:55Z",
      "delivery_partner_id": null,
      "statement_id": "1cceffd7-0efd-432a-aedc-7be2d6cc72a2",
      "clawback_statement_id": null,
      "ineligible_for_funding_reason": null,
      "mentor_id": null,
      "uplift_paid": true,
      "evidence_held": null
      "has_passed": null
    }
  }
}
```
$EndContent
$EndAccordion

## View financial statement payment dates  

<div class="govuk-inset-text">The following endpoints are only available for systems integrated with API v3 onwards. They will not return data for API v1 or v2.</div>

Providers can view up to date payment cut-off dates, upcoming payment dates, and check to see whether output payments have been made by DfE.

$Accordion

$Heading
### View all statement payment dates
$EndHeading

$Content
```
GET /api/v3/statements
```

An example response body is listed below. 

For more detailed information see the specifications for this [view all statements endpoint.](api-reference/reference-v3.html#api-v3-statements-get)

#### Example response body:

```
{
  "data": [
    {
      "id": "cd3a12347-7308-4879-942a-c4a70ced400a",
      "type": "statement",
      "attributes": {
        "month": "5",
        "year": "2022",
        "type": "npq",
        "cohort": "2021",
        "cut_off_date": "2022-04-30",
        "payment_date": "2022-05-25",
        "paid": true
      }
    }
  ]
}
```
$EndContent

$Heading
### View specific statement payment dates
$EndHeading

$Content
```
GET /api/v3/statements/{id}
```

Providers can find statement IDs within [previously submitted declaration](/api-reference/npq/guidance/#view-a-specific-previously-submitted-declaration) response bodies.

An example response body is listed below. 

For more detailed information see the specifications for this [view a specific statement endpoint.](/api-reference/reference-v3.html#api-v3-statements-id-get)

#### Example response body:

```
{
  "data": {
    "id": "cd3a12347-7308-4879-942a-c4a70ced400a",
    "type": "statement",
    "attributes": {
      "month": "5",
      "year": "2022",
      "type": "npq",
      "cohort": "2021",
      "cut_off_date": "2022-04-30",
      "payment_date": "2022-05-25",
      "paid": true
    }
  }
}
```
$EndContent

$EndAccordion