---
title: Changes for the 2025/26 academic year
weight: 3
---

# Changes for the 2025/26 academic year  

Published: 25 February 2025

Updated: 15 April 2025

This is a summary of planned changes to API processes lead providers will see when early career teacher (ECT) and mentor registrations open (date to be confirmed). 

We’ll update this section with any further details providers might need to help them test their endpoint integrations in the run up to registrations opening. 

## Reduced declarations for mentors starting training in the 2025/26 academic year 

We're removing the following declarations from the `POST participant-declarations` endpoint for mentors starting in the 2025/26 academic year:

* `retained-1`
* `retained-2`
* `retained-3`
* `retained-4`
* `extended-1`
* `extended-2`
* `extended-3`

This means there’ll be just 2 mentor declarations from the 2025/26 academic year onwards:  

* `started`
* `completed`

<div class="govuk-inset-text">
  Providers will need to update their integrations to support submitting 2 milestones only.
  Providers will see a 422-error message if they try to submit retained or extended declarations for a mentor who starts training in the 2025/26 academic year.
</div>

## Evidence types for the 2025/26 academic year

We'll be updating the `evidence_held` values lead providers will be able to use when they submit participant declarations for the 2025/26 academic year intake of ECTs and mentors.

These values represent the evidence lead providers hold to show participants have met the retention criteria for the current milestone period. 

For the 2025/26 academic year, every `declaration_type` will have its own `evidence_held` values (see tables). In previous years we’d applied the `training-event-attended`, `self-study-material-completed` and `other` values across all declaration types.

### Declaration and evidence types for ECTs 

| Declaration type   | Evidence held values |
| -------------------- | ---------------------- |
| `started`   |  <ul class="govuk-list govuk-list--bullet"><li>`training-event-attended`</li> <li>`self-study-material-completed`</li> <li>`other`</li> <li>`materials-engaged-with-offline` (new value)</li></ul> |
| `retained-1` |  <ul class="govuk-list govuk-list--bullet"><li>`training-event-attended`</li> <li>`self-study-material-completed`</li> <li>`other`</li> <li>`materials-engaged-with-offline` (new value)</li></ul> |
| `retained-2` |  <ul class="govuk-list govuk-list--bullet"><li>`75-percent-engagement-met` (new value)</li> <li>`75-percent-engagement-met-reduced-induction` (new value)</li></ul> |
| `retained-3` |  <ul class="govuk-list govuk-list--bullet"><li>`training-event-attended`</li> <li>`self-study-material-completed`</li> <li>`other`</li> <li>`materials-engaged-with-offline` (new value)</li></ul> |
| `retained-4` |  <ul class="govuk-list govuk-list--bullet"><li>`training-event-attended`</li> <li>`self-study-material-completed`</li> <li>`other`</li> <li>`materials-engaged-with-offline` (new value)</li></ul> |
| `extended-1` |  <ul class="govuk-list govuk-list--bullet"><li>`training-event-attended`</li> <li>`self-study-material-completed`</li> <li>`other`</li> <li>`materials-engaged-with-offline` (new value)</li></ul> |
| `extended-2` |  <ul class="govuk-list govuk-list--bullet"><li>`training-event-attended`</li> <li>`self-study-material-completed`</li> <li>`other`</li> <li>`materials-engaged-with-offline` (new value)</li></ul> |
| `extended-3` |  <ul class="govuk-list govuk-list--bullet"><li>`training-event-attended`</li> <li>`self-study-material-completed`</li> <li>`other`</li> <li>`materials-engaged-with-offline` (new value)</li></ul> |
| `completed` |  <ul class="govuk-list govuk-list--bullet"><li>`75-percent-engagement-met` (new value)</li> <li>`75-percent-engagement-met-reduced-induction` (new value)</li> <li> `one-term-induction` (new value) </li></ul>|

### Declaration and evidence types for mentors 

| Declaration type   | Evidence held values |
| ------------- | ------------- |
| `started`   |  <ul class="govuk-list govuk-list--bullet"><li>`training-event-attended`</li> <li>`self-study-material-completed`</li> <li>`other`</li> <li>`materials-engaged-with-offline` (new value)</li></ul> |
| `completed` |  <ul class="govuk-list govuk-list--bullet"><li>`75-percent-engagement-met` (new value)</li> <li>`75-percent-engagement-met-reduced-induction` (new value)</li></ul> |

<div class="govuk-inset-text">New evidence types are not compatible with previous cohorts. If providers try using a new evidence type for an older cohort declaration, it will not work and they’ll see a 422-error message.</div>

## Changes to induction programme types 

We’ll be making the following changes to the `induction_programme_choice` field options in the `GET schools/ecf` and `GET schools/ecf/{id}` endpoints:

* `core-induction-programme` and `diy` will change to `school-led`
* `full-induction-programme` and `school-funded-full-induction-programme` will change to `provider-led`

<div class="govuk-inset-text">These changes will apply across all cohorts. We’ll contact providers directly to ensure their integrations can support the new values.</div>  

### Change to withdrawal reason value to reflect new programme types terminology 

To align with the new programme types terminology, we’ll be changing one of the options in the `reason` field for the `PUT participants/ecf/{id}/withdraw` endpoint: 
 
* `school-left-fip` will change to `switched-to-school-led`   

As a result, we’ll update records across all cohorts that have previously used the `school-left-fip` value. This is not expected to affect how the endpoint functions. However, lead providers will need to update the options when submitting withdrawal requests to pass through the new value.  

Records that have already been withdrawn using the old value will surface the new value and have a modified `updated_at` timestamp.  

## API testing and integration

The introduction of the 2025 contracts requires updates to the API service. 

To help lead providers prepare for the opening of ECF registration, we'll run a testing window throughout May 2025. 

Refer to our [release notes](/api-reference/release-notes.html) for all the relevant spec changes.

### Timelines 

As set out in the Model Call-off Contract, lead providers must complete testing by 1 June 2025. This is to ensure there’s enough time to resolve any urgent issues or integration challenges ahead of registration opening for the 2025/26 academic year on 30 June 2025. 

#### Timeline overview 

| Date | Activity |  
| -------- | -------- | 
| By 22 April | Test data added to test environment (sandbox) 
| By 30 April | Test scenarios shared with lead providers |  
| Throughout May | DfE product team will join digital check-ins | 
| By 16 May | Providers should attempt all test scenarios | 
| By 1 June | Deadline for providers to submit testing evidence | 
| By 6 June | Deadline for providers to raise any issues or defects | 
| By 13 June | DfE will have resolved any identified defects |  
| 16 June | Soft launch of registration (for selected schools) |  
| 30 June | Full registration opens |  

### Affected API endpoints 

These changes affect the following endpoints: 

* `GET schools` – affected by induction type changes
* `GET participants` and `PUT participants/ecf/{id}/withdraw` – includes new withdrawal reasons
* `POST participant-declarations` – updated for mentor funding and evidence types
* `GET participant-declarations` – updated for mentor funding and evidence types 

### Support from DfE 

During testing, we recommend lead providers: 

* use existing Slack channels and check-in sessions to raise questions 
* review all provided API documentation and guidance 

We will: 

* give timely access to technical support, including one to one sessions (contact digital engagement leads for more details)
* monitor testing to anticipate provider needs 

### Integration changes to consider 

#### Evidence types 

New values must be added to evidence types to meet 2025 policy requirements. Pay close attention to: 

* `retained-2` declarations for ECTs
* `completed` declarations for all participants 

#### Mentor declarations 

Providers will only be able to submit `started` and `completed` declarations for mentors who start training from June 2025 onwards. The API will return a 422 error if providers submit `retained` or `extended` declarations, as these are not accepted.

#### School induction types 

Language used in the `GET schools` endpoint will change. This is not expected to affect how the endpoint functions. However, lead providers should: 

* resync with the API
* review downstream systems for impacts 
 
#### Withdrawal reasons 

We’re adding a new value for participant withdrawals: `switched-to-school-led` 

Providers must ensure their systems can both submit and process this new value. 

### API integration testing 

Lead providers must test to confirm: 

* functionality has not been lost
* all common journeys work as expected
* their systems integrate correctly with the updated API 

#### Testing areas 

Providers will be expected to complete and provide evidence for the following: 

##### Updated evidence types 

Test declaration submissions using these values: 

* `started` (ECTs and mentors)
* `retained-1`, `retained-2`, `retained-3`, `retained-4` (ECTs only)
* `completed` (ECTs and mentors)
* `extended` (ECTs only) 

##### Declarations

Providers must demonstrate correct declaration submissions for both ECTs and mentors.

##### Withdrawal scenarios 

Test withdrawing a participant using the new reason: `switched-to-school-led` 

##### Creating partnerships 

This will not be tested directly. However, to submit declarations, a lead provider must first create a partnership between an eligible school and a delivery partner. 

##### Full sync tests 

Run full syncs on: 

* `GET schools`
* `GET participants`
* `GET participant-declarations` 

Providers must check that changes are accepted and that they remain within rate limits. 

### Test data 

We'll add test data to the ECF sandbox by 22 April 2025. This will include: 

* schools with different induction types for the 2024 and 2025 cohorts
* assigned delivery partners for those cohorts
* participants attached to each school 

If providers need additional data or encounter issues, they should contact their digital engagement lead with detailed information. 

### Deployment readiness checklist 

Before the registration window opens, lead providers must confirm to us that: 

* integrations have been reviewed and updated 
* test scenarios have been completed and evidenced
* full syncs using updated APIs are functioning correctly 

We also welcome providers to share their test plans, feedback and concerns via the DfE Slack channel. 

### Related links 

[ECF test environment (sandbox)](https://sb.manage-training-for-early-career-teachers.education.gov.uk)

[ECF API guidance](https://manage-training-for-early-career-teachers.education.gov.uk/api-reference)
