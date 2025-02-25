---
title: Changes for the 2025/26 academic year
weight: 3
---

# Changes for the 2025/26 academic year  

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

Providers will need to update their integrations to support submitting 2 milestones only. 

Providers will see a 422-error message if they try to submit retained or extended declarations for a mentor who starts training in the 2025/26 academic year. 

## Evidence types for the 2025/26 academic year

We'll be updating the `evidence_held` values lead providers will be able to use when they submit participant declarations for the 2025/26 academic year intake of ECTs and mentors.

These values represent the evidence lead providers hold to show participants have met the retention criteria for the current milestone period. 

For the 2025/26 academic year, every `declaration_type` will have its own `evidence_held` values (see tables). In previous years we’d applied the `training-event-attended`, `self-study-material-completed` and `other` values across all declaration types.

### Declaration and evidence types for ECTs 

| Declaration Type   | Evidence held values |
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

## What to test ahead of the 2025/26 academic year’s registration opening 

We recommend providers check their integrations can: 

* support all new evidence types  
* submit `one-term-induction` as `evidence_held` for `completed` ECT declarations
* supply evidence types for `started` declarations

## Changes to induction programme types 

We’ll be making the following changes to the `induction_programme_choice` field options in the `GET schools` endpoint:

* `core-induction-programme` and `diy` will all be known as `school-led`
* `full-induction-programme` and `school-funded-full-induction-programme` will change to `provider-led`

<div class="govuk-inset-text">These changes will apply across all cohorts. We’ll contact providers directly to ensure their integrations can support the new values.</div>

## Seed data for testing 

We’ll generate seed data to go with each release to help providers test the new scenarios. Providers should contact us via the usual channels if they need more data or specific formats.  

## Timelines 

We plan to have all these changes ready for integration well ahead of registration opening for the 2025/26 academic year’s intake.  

We’ll update the test environment in the following order: 

1. Mentor funding (late February 2025).
2. Evidence types (late February 2025).
3. Induction programme type changes (following provider consultation, spring 2025).

Refer to our [release notes](/api-reference/release-notes.html) for all the relevant spec changes.

As always, we’d welcome feedback any of these updates before they go into production.
