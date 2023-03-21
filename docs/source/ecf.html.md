---
title: ECF-based training management
weight: 3
---

# ECF-based training management

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

## Notifying that an ECF participant is taking a break from their course

This operation allows the provider to tell the DfE that a participant has deferred from their ECF course.

A participant is deemed to have deferred from an ECF course if he or she will be resuming it at a later date.

### Provider defers a participant

Submit the deferral notification to the following endpoint

```
PUT /api/v1/participants/{id}/defer
```

This will return an [ECF participant response](/api-reference/reference-v1#schema-ecfparticipantresponse) with the updates to the record included.

See [defer ECF participant](/api-reference/reference-v1#api-v1-participants-ecf-id-defer-put) endpoint.

## Notifying that an ECF participant is resuming their course

This functionality allows the provider to inform the DfE that a participant has resumed an ECF course.

### Provider resumes a participant

Submit the resumed notification to the following endpoint

```
PUT /api/v1/participants/{id}/resume
```

This will return an [ECF participant record](/api-reference/reference-v1#schema-ecfparticipantresponse) with the updates to the record included.

See [resume ECF participant](/api-reference/reference-v1#api-v1-participants-ecf-id-resume-put) endpoint.

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

### Standard induction

A usual 2 year induction covers 6 terms (3 in each academic year). The payment model for those following a standard induction is therefore equal to 1 milestone payment for each of the 6 terms you are supporting a participant. We are allowing functionality for providers to switch participants onto the following standard schedules:

* `ecf-standard-september`
* `ecf-standard-january`
* `ecf-standard-april`

Standard schedules will be subject to milestone validation as outlined in the tables below.

### Standard induction starting in September
Participants should be tagged as `ecf-standard-september` if they are starting their course before the **30 November 2021** and are expected to complete their training over two academic years.

| Retention Point                         | Milestone Date      | Payment Made       |
| --------------------------------------- | ------------------- | ------------------ |
| Output 1 - Participant Start (20%)      | 30th November 2021  | 30th November 2021 |
| Output 2 – Retention Point 1 (15%)      | 31st January 2022   | 28th February 2022 |
| Output 3 – Retention Point 2 (15%)      | 30th April 2022     | 31st May 2022      |
| Output 4 – Retention Point 3 (15%)      | 30th September 2022 | 31st October 2022  |
| Output 5 – Retention Point 4 (15%)      | 31st January 2023   | 28th February 2023 |
| Output 6 – Participant Completion (20%) | 30th April 2023     | 31st May 2023      |

### Standard induction starting in January
Participants should be tagged as `ecf-standard-january` if they are starting their course on or after **1 December** and are expected to complete their training over 2 years.

| Retention Point                         | Milestone Date      | Payment Made       |
| --------------------------------------- | ------------------- | ------------------ |
| Output 1 - Participant Start (20%)      | 31st January 2022   | 28th February 2022 |
| Output 2 – Retention Point 1 (15%)      | 30th April 2022     | 31st May 2022      |
| Output 3 – Retention Point 2 (15%)      | 30th September 2022 | 31st October 2022  |
| Output 4 – Retention Point 3 (15%)      | 31st January 2023   | 28th February 2023 |
| Output 5 – Retention Point 4 (15%)      | 30th April 2023     | 31st May 2023      |
| Output 6 – Participant Completion (20%) | 31st October 2023   | 30th November 2023 |

### Standard induction starting in April

Participants should be tagged as `ecf-standard-april` if they are starting their course on or after **1 February** and are expected to complete their training over 2 years.

| Retention Point                         | Milestone Date      | Payment Made       |
| --------------------------------------- | ------------------- | ------------------ |
| Output 1 - Participant Start (20%)      | 30th April 2022     | 31st May 2022      |
| Output 2 – Retention Point 1 (15%)      | 30th September 2022 | 31st October 2022  |
| Output 3 – Retention Point 2 (15%)      | 31st January 2023   | 28th February 2023 |
| Output 4 – Retention Point 3 (15%)      | 30th April 2023     | 31st May 2023      |
| Output 5 – Retention Point 4 (15%)      | 31st October 2023   | 30th November 2023 |
| Output 6 – Participant Completion (20%) | 31st January 2024   | 28th February 2024 |


### Non-standard induction
Following the same principles of those on a standard induction, providers will be paid the equivalent of one milestone payment for each of the terms they are supporting a participant. Non-standard schedules will not be subject to milestone validation.

Under a non-standard schedule, the API will accept any declarations once the first milestone period for the schedule has started. For example, if a participant is on an ecf-extended-september schedule, the API will accept any type of declaration, such as a start, retention-1 or completion, from 1 September 2021. Providers will still be expected to evidence any declarations and why a participant is following a non-standard induction.

We are allowing functionality for providers to switch participants onto the following non-standard schedules:

* `ecf-extended-september`
* `ecf-extended-january`
* `ecf-extended-april`
* `ecf-reduced-september`
* `ecf-reduced-january`
* `ecf-reduced-april`
* `ecf-replacement-september`
* `cf-replacement-january`
* `ecf-replacement-april`

The non-standard induction schedules are detailed below.

### Extended schedule
For participants that expect to complete their induction over a period greater than two years, with the schedule reflecting the month when the participant starts. For example, part time ECTs:

* `ecf-extended-september`
* `ecf-extended-january`
* `ecf-extended-april`

### Reduced schedule
For participants that expect to complete their induction over a period less than 2 years, with the schedule reflecting the month when the participant starts:

* `ecf-reduced-september`
* `ecf-reduced-january`
* `ecf-reduced-april`

### Replacement mentors
For mentors that are replacing a mentor for an ECT that is part way through their training with the schedule reflecting the month when the replacement starts:

* `ecf-replacement-september`
* `ecf-replacement-january`
* `ecf-replacement-april`

Where a mentor is already mentoring an ECT and they replace a mentor for a second ECT, the first ECT takes precedence. In this instance, the provider should not change the mentor’s schedule.

The DfE expects that a replacement mentor's training, and therefore any declarations a provider submits for them, will align with the ECT they are mentoring. Say a replacement mentor begins mentoring an ECT part way through the ECT’s induction. The provider has already submitted a start declaration for the previous mentor. Now, the provider makes a retention-1 declaration for the ECT. The department would expect that any declaration made for the replacement mentor in the same milestone period as that made for the ECT would also be a retention-1 declaration.

## Notifying that an ECF participant has withdrawn from their course

This operation allows the provider to tell the DfE that a participant has withdrawn from their ECF course.

A participant that withdraws in a given milestone period after the submission of a retained event for the same period, will be paid for that period.

A participant that withdraws before the started milestone cut-off date will not be paid for by the department.

### Provider withdraws a participant

Submit the withdrawal notification to the following endpoint

```
PUT /api/v1/participants/ecf/{id}/withdraw
```

This will return an [ECF participant record](/api-reference/reference-v1#schema-ecfparticipantresponse) with the updates to the record included.

See [withdraw ECF participant](/api-reference/reference-v1#api-v1-participants-ecf-id-withdraw-put) endpoint.

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
