---
title: Guidance
weight: 2
---

# Guidance

## Overview of API requests
1. A person submits an application for an NPQ course via the DfE online service
2. Providers view NPQ application data via the API 
3. Providers complete their own suitability and application processes 
4. Providers accept or reject applications via the API and onboarding participants onto their systems
5. Providers train participants as per details set out in the contract
6. Providers submit `started` declarations via the API to notify DfE that participants have started their courses
7. DfE pay providers output payments for `started` declarations
8. Providers continue to train participants as per details set out in the contract
9. Providers submit `retained` declarations via the API to notify DfE participants have continued in training for a given milestone
10. DfE pays providers output payments for `retained` declarations
12. Providers complete training participants as per details set out in the contract
12. Providers will submit `completed` declarations via the API, including participant outcomes, to notify DfE participants have completed the course
13. DfE will pay providers output payments for `completed` declarations

Changes can happen during training; some participants may not complete their course within the standard schedule, or at all. Providers will need to update relevant data using the API.

{inset-text} Note, DfE will only make payments for participants if providers have accepted course applications. Accepting applications is a separate request to submitting a ‘started’ declaration (which notifies DfE a participant has started training). [Find out more about declaration states](api-reference/npq/definitions-and-states/#declaration-states) {/inset-text}

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

{inset-text} Providers must accept or reject applications before they start the course. They must inform applicants of the outcome of their NPQ applications, regardless of whether their course application has been accepted or rejected. {/inset-text}

### View all applications

```
 GET /api/v3/npq-applications
```

Note, providers can also filter results to see more specific or up to date data by adding `cohort`, `participant_id` and `updated_since` filters to the parameter. For example: 

```
GET /api/v3/npq-applications?filter[cohort]=2021&filter[participant_id]=7e5bcdbf-c818-4961-8da5-439cab1984e0&filter[updated_since]=2020-11-13T11:21:55Z
```

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
        "participant_id": "7a8fef46-3c43-42c0-b3d5-1ba5904ba562",
        "full_name": "Isabelle MacDonald",
        "email": "isabelle.macdonald2@some-school.example.com",
        "email_validated": true,
        "teacher_reference_number": "1234567",
        "teacher_reference_number_validated": true,
        "school_urn": "106286",
        "school_ukprn": "10079319",
        "headteacher_status": "no",
        "eligible_for_funding": true,
        "funding_choice": "trust",
        "course_identifier": "npq-leading-teaching",
        "lead_mentor": null,
        "itt_provider": "University of Southampton"
      }
    }
  ]
}
```

### Accept an application 

Providers should accept applications for those they want to enrol onto a course. Reasons to accept applications include (but are not limited to) the participant: 

* having funding confirmed
* being suitable for their chosen NPQ course
* having relevant support from their school

```
POST /api/v3/npq-applications/{id}/accept
```

The request parameter must include the `id` of the corresponding NPQ application. 

An example response body is listed below. Successful requests will return a response body including updates `status` attribute. 

{inset-text} Note, the API will prevent more than one provider accepting applications for the same course by automatically updating the application status or returning an error message. {/inset-text}

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

{inset-text} Providers must inform applicants of the outcome of their successful NPQ application. {/inset-text}

### Reject an application

Providers should reject applications for those they do not want to enrol onto a course. Reasons to reject applications include (but are not limited to) the participant: 

* having been unsuccessful in their application process
* not having secured funding
* wanting to use another provider
* wanting to take on another course
* no longer wants to take the course 

```
POST /api/v3/npq-applications/{id}/reject
```
The request parameter must include the `id` of the corresponding NPQ application. 

An example response body is listed below. Successful requests will return a response body including updates `status` attribute. 

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

{inset-text} Providers must inform applicants of the outcome of their unsuccessful NPQ application. {/inset-text}

### Update an application due to a change in circumstance

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

## View and update participant records

Once a provider has accepted an application, they can view and update data to notify DfE that a participant has: 

* [deferred their course](LINK NEEDED)
* [resumed their course](LINK NEEDED)
* [withdrawn from their course](LINK NEEDED)
* [changed their course schedule](LINK NEEDED)
* [an updated course outcome](LINK NEEDED)

### View all participant data

```
GET /api/v3/participants/npq
```

Note, providers can also filter results by adding `updated_since` filters to the parameter. For example: 

```
GET /api/v{n}/participants/ecf?filter[updated_since]=2020-11-13T11:21:55Z
```

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

### View a single participant’s data

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

### Notify DfE a participant has taken a break (deferred) from training

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

### Notify DfE a participant has resumed training

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

###  Notify DfE a participant has withdrawn from training

A participant can choose to withdraw from an NPQ course at any time. Providers must notify DfE of this via the API.

```
 PUT /api/v3/participants/npq/{id}/withdraw
```

An example request body is listed below. 

Successful requests will return a response body including updates to the `training_status` attribute.

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

{inset-text}
#### Providers should note: 

* The API will **not** allow withdrawals for participants who have not had a `started` declaration submitted against them. If a participant withdraws before a `started` declaration has been submitted, providers should inform their contract manager who can advise
* DfE will **only** pay for participants who have had, at a minimum, a `started` declaration submitted against them
* If a participant is withdrawn later in their course, DfE will pay providers for any declarations submitted where the `declaration_date` is before the date of the withdrawal
* The amount DfE will pay depends on which milestones have been reached with declarations submitted before withdrawal. [View NPQ schedules and milestone dates](/api-reference/npq/schedules_and-milestone-dates)
{/inset-text}

### Notify DfE a participant has changed their training schedule

Participants follow leadership or specialist training schedules. 

All participants will be registered by default schedule depending on when their application is accepted. Providers must notify the DfE of any schedule change.

```
 PUT /api/v3/participants/npq/{id}/change-schedule
```

An example request body is listed below. 

Successful requests will return a response body including updates to the `schedule_identifier` attribute.

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





## Declaring that an NPQ participant has started their course

This scenario begins after it has been confirmed that an NPQ participant is ready to begin their induction training.

### Provider confirms an NPQ participant has started

onfirm an NPQ participant has started their induction training before Milestone 1.

```
POST /api/v1/participant-declarations
```

With a [request body containing an NPQ participant declaration](/api-reference/reference-v1#schema-npqparticipantstarteddeclaration).

This returns [participant declaration](/api-reference/reference-v1#schema-singleparticipantdeclarationresponse).

This endpoint is idempotent - submitting exact copy of a request will return the same response body as submitting it the first time.

See [confirm NPQ participant declarations](/api-reference/reference-v1#api-v1-participant-declarations-post) endpoint.

### Provider records the NPQ participant declaration ID

Store the returned NPQ participant declaration ID for future management tasks.

## Declaring that an NPQ participant has reached a retained milestone

This scenario begins after it has been confirmed that an NPQ participant has completed enough of their course to meet a milestone.

### Provider confirms an NPQ participant has been retained

Confirm an NPQ participant has been retained by the appropriate number of months for this retained event on their NPQ course.

An explicit `retained-x` declaration is required to trigger output payments. You should declare this when a participant has reached a particular milestone in line with contractual reporting requirements.

```
POST /api/v1/participant-declarations
```

With a [request body containing an NPQ participant retained declaration](/api-reference/reference-v1#schema-npqparticipantretaineddeclaration).

This returns [participant declaration](/api-reference/reference-v1#schema-singleparticipantdeclarationresponse).

See [confirm NPQ participant declarations](/api-reference/reference-v1#api-v1-participant-declarations-post) endpoint.

### Provider records the NPQ participant declaration ID 

Store the returned NPQ participant declaration ID for future management tasks.

## Declaring that an NPQ participant has completed their course

This scenario begins after it has been confirmed that an NPQ participant has completed their course.

Providers should declare this when a participant has reached their final milestone and completed their NPQ course with a pass or fail outcome.

An explicit `completed` declaration is required to trigger output payments.

### Provider confirms an NPQ participant has completed their course

Confirm a participant has completed their NPQ course.

```
POST /api/v1/participant-declarations
```

The request body must contain all attributes described in the [NPQ participant completed declaration](/api-reference/reference-v1.html#schema-npqparticipantdeclarationcompletedattributesrequest), including a value in the `has_passed` attribute.

This returns [participant declaration](/api-reference/reference-v1#schema-singleparticipantdeclarationresponse).

See specifications for the [confirm NPQ participant declarations](/api-reference/reference-v1#api-v1-participant-declarations-post) endpoint.

### Provider records the NPQ participant declaration ID

Store the returned NPQ participant declaration ID for future management tasks.

## Removing a declaration submitted in error

This scenario begins when a provider needs to correct participant data that may have been submitted in error.

This operation allows the provider to void a declaration that has been previously submitted.

### Provider voids a declaration

Void an NPQ participant declaration

```
PUT /api/v1/participant-declarations/{id}/void
```

This will return a [participant declaration record](/api-reference/reference-v1#schema-participantdeclarationresponse) with the updates to the record included.

If providers void `completed` declarations where a participant had passed the assessment (`"has_passed": true`), then this outcome will also be retracted and the participants will be notified.

See specifications for the [void participant declaration](/api-reference/reference-v1#api-v1-participant-declarations-id-void-put) endpoint.

## Listing NPQ participant outcomes

This scenario begins after a provider has submitted a `completed` declaration for an NPQ participant and confirmed their outcome.

This operation allows the provider to view pass, fail or voided outcomes for NPQ participants.

### Provider views outcomes for an NPQ participant

View outcomes for a specific NPQ participant.

```
GET /api/v1/participant/npq/{participant_id}/outcomes
```

This will return an [NPQ outcomes response](/api-reference/reference-v1.html#schema-npqoutcomesresponse), including a `state` value to show: 

* outcomes submitted (`passed` or `failed)
* if the `completed` declaration has been voided and the outcome retracted (`voided`)

See specifications for the [participant outcome](/api-reference/reference-v1.html#api-v1-participants-npq-participant_id-outcomes-get) endpoint.

### Provider views outcomes for all NPQ participants

View outcomes for all NPQ participants.

```
GET /api/v1/participant/npq/outcomes
```

This will return an [NPQ outcomes response](/api-reference/reference-v1.html#schema-npqoutcomesresponse), including `state` values to show: 

* outcomes submitted (`passed` or `failed`)
* if any `completed` declarations have been voided and the outcomes retracted (`voided`)

See specifications for the [participant outcome](/api-reference/reference-v1.html#api-v1-participants-npq-outcomes-get) endpoint.

## Updating NPQ participant outcomes 

This scenario begins after a provider has submitted a `completed` declaration for a participant, including their course outcome.

This operation allows providers to update an NPQ participant's outcome. Providers can also view a list of all [previously submitted declarations](/api-reference/npq-usage.html#checking-all-previously-submitted-declarations).

Providers may need to update an outcome if the previously submitted data was inaccurate. For example, a provider should update the outcome if:
* the reported NPQ outcome was incorrect
* the reported date the participant received their outcome was incorrect
* a participant has retaken their NPQ assessment and their outcome has changed.

### Updating NPQ outcomes 

Submit an updated NPQ outcome.

```
POST /api/v1/participant/npq/{participant_id}/outcomes
```

The request body must contain all attributes described in the [NPQ participant outcome schema](/api-reference/reference-v3.html#schema-npqoutcomerequest-example), including updated values for the `completion_date` and `state` attributes.

This returns an [NPQ outcomes response](/api-reference/reference-v3.html#schema-npqoutcomeresponse) including updates to the record.

See specifications for the [NPQ outcomes](/api-reference/reference-v1.html#api-v1-participants-npq-participant_id-outcomes-post) endpoint. 

## Listing participant declaration submissions 
This is how you see all the declarations you have made. This functionality allows the provider to check declaration submissions and identify any that are missing.

If declarations are missing, following other guidance by going to [Declaring that an NPQ participant started their course](#declaring-that-an-ecf-participant-has-started-their-course).

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