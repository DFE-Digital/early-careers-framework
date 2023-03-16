---
title: Release notes
weight: 8
---

# Release notes

If you have any questions or comments about these notes, please contact DfE via Slack or email.

## 15th March 2023

Providers will see reduced errors and inconsistencies associated with `participant_id` values.

Providers have previously reported seeing different `participant_id` values associated with a single participant. For example, an NPQ provider may have seen a `participant_id` value of XXX via the applications endpoint, but when submitting a declaration for the same participant, the response body returned a participant_id value of YYY.

These types of inconsistencies were appearing because the API was exposing the underpinning ECF and NPQ programme data models. The DfE has now updated the API logic to align `participant_id` values across various API endpoints and prevent related issues.

Note, providers may need to update IDs held on their systems. The DfE will contact providers with further instruction if:

- they need to reconcile multiple `participant_ids` into a single true `participant_id`
- they need to replace a `participant_id` as a result of this API release

While the expected volume of future instances is expected to be very low (where single participants are registered with multiple `participant_ids`), providers who identify issues should contact the DfE via existing support channels. The DfE will fix errors by 'retiring' one of the IDs, then associating all records and data under the remaining ID. The DfE will inform providers as to which `participant_id` they will need to record on their systems.

## 28th February 2023

Providers can now review updated draft documentation for API version 3.0.0. Presentations and further feedback sessions on the proposed changes will be arranged with providers directly.

Note, providers are not yet able to use API version 3.0.0 in any environment. Functionality should be available in the sandbox environment in May 2023, and in the live production environment in June 2023.

Initial API draft documentation was shared with providers in Summer 2022. Following workshops with providers in November and December, DfE have gathered insights and incorporated feedback into the newly published draft documentation.

Important changes to be aware of for API version 3.0.0:
* **New endpoints will become available** - To address feedback from providers, DfE will avoid adding new attributes to existing endpoints (and their response bodies) where possible, and will instead create new endpoints to meet provider needs.
* **ECF providers will receive nested participant responses** - To support the need to see participant details for those that train as an ECT and/then as a mentor with the same provider, the API will present nested data for ECF participant responses.
* **ECF providers will be able to view transfer details** - New endpoints will allow providers to view details for any participants (who they train or will train) who have transferred to new schools. Existing ECF participant endpoints will present a `participant_status` attribute which will identify participants that are leaving or joining.
* **ECF providers will be able to view details for ‘unfunded’ mentors** - New endpoints will allow providers to view details for mentors linked to ECTs, but who are not eligible for DfE funding.
* **ECF providers will be able to identify schools they could partner with** - New endpoints will allow providers to view details for schools they could contact to partner with.
* **ECF and NPQ providers will see new attributes when using declaration endpoints** - The API will continue to support NPQ and ECF declarations via existing endpoints. Providers may therefore see `null` values for attributes that do not apply to their declaration’s course type. For example, the `delivery_partner_id` attribute for an NPQ declaration will always be `null`.

## 24th February 2023
When [submitting completed ECF declarations](/api-reference/ecf-usage.html#declaring-that-an-ecf-participant-has-completed-their-course), providers should note that `evidence_held` is a mandatory attribute and must be included in the request body. API documentation has been updated in line with contractual requirements.

Providers can only submit accepted `evidence_held` values. These signify the type of evidence held by a provider to demonstrate that a participant has met the retention criteria for the milestone period. The accepted values are:
* `"evidence_held": training-event-attended`
* `"evidence_held": self-study-material-completed`
* `"evidence_held": other`

Note, other mandatory attributes to include in the request body for completed ECF declaration submissions are `participant_id`, `declaration_type`, `declaration_date` and `course_identifier`.

## 23rd February 2023
Initial teacher training (ITT) lead mentors who are not employed by schools are now eligible for DfE funding.

During their registration journey, applicants for the leading teacher development NPQ will enter data to identify themselves as ITT lead mentors and validate their funding eligibility.

Providers will see two new data attributes when viewing application data via the endpoint `GET /api/v1/npq-applications`:
* `lead_mentor` - This signifies whether an applicant is a lead mentor (`"lead_mentor": true`) or not (`"lead_mentor": false`)
* `itt_provider` - This will show the name of the accredited provider

Note, unlike other NPQ applicants, ITT lead mentors do not need to enter some information on their registration journey. The following attributes will have null values:
* `employer_name`
* `employment_role`
* `school_urn`

## 26th January 2023

Providers are now able to submit, view and update NPQ participant outcomes in the production environment.

When an NPQ participant completes their course, their final assessment will determine a pass or fail outcome. Providers are required to notify DfE of outcomes, and provide updated outcomes as required.

DfE will then notify the TRA who will issue certificates to any participants who have passed their NPQ course.

Note, this functionality became available in the sandbox environment on 16th January 2023. Read more detailed guidance below on:
* [Submitting NPQ outcomes in 'completed' declarations](#submitting-npq-outcomes)
* [Updating NPQ outcomes](#updating-npq-outcomes)
* [Viewing NPQ outcomes for participants](#viewing-npq-outcomes)

## 16th January 2023
Providers are now able to submit, view and update NPQ participant outcomes in the sandbox environment. Note, providers will be notified ahead of this functionality becoming available in the production environment.

When an NPQ participant completes their course, their final assessment will determine a pass or fail outcome. Providers are now required to notify DfE of outcomes as part of `completed` declaration submissions, and provide updated outcomes as required.

DfE will then notify the TRA who will issue certificates to any participants who have passed their NPQ course.

### Submitting NPQ outcomes in 'completed' declarations
Providers must include participant outcomes as part of NPQ `completed` declaration submissions. The mandatory `has_passed` attribute must be included as part of the request body for the following endpoint:

```
POST /api/v1/participant-declarations
```

Providers can submit `has_passed` values as follows:

* `"has_passed": true` - This signifies a participant has passed their course.
* `"has_passed": false` - This signifies a participant has failed their course.

`completed` declaration submissions which do not include outcomes will be rejected as invalid requests.

If providers void `completed` declarations where a participant had passed assessment (`"has_passed": true`), then this outcome will also be retracted and the participants will be notified.

### Updating NPQ outcomes
Providers can update participant outcomes (defined by the `state` attribute) if they made an error in the data originally submitted, or if the participant fails, retakes and goes on to pass their assessment.

Providers should include updated values for the NPQ `state` and `completion_date`, as well as the explicit `course_identifier` for the new endpoint:

```
POST /api/v1/participants/npq/{participant_id}/outcomes
```

Providers can submit `state` values as follows:
* `"state": passed` - This will update the record to signify a participant has passed their course.
* `"state": failed` - This will update the record to signify a participant has failed their course.

### Viewing NPQ outcomes for all participants
Providers can view all outcomes submitted for NPQ participants by using the following endpoints. Outcomes will be defined in the responses by the state attribute with values including:

* `"state": passed` - This signifies a participant has passed their course.
* `"state": failed` - This signifies a participant has failed their course.
* `"state": voided` - This signifies a `completed` declaration has since been voided and therefore the associated outcome retracted.

Providers can view outcomes for all NPQ participants by using the new endpoint:
```
GET /api/v1/participants/npq/outcomes
```

Providers can view outcomes for a specific NPQ participant by using the new endpoint:
```
GET /api/v1/participants/npq/{participant_id}/outcomes
```

## 21st September 2022
Providers may need to consider funding and administrative implications of non-UK participants registering for NPQs. Providers can now identify non-UK registrations using three new participant data fields in the API:

1. `teacher_catchment` - This field will indicate whether or not the participant is UK-based.
    * If `true` then the registration relates to a participant who is UK-based.
    * If `false` then the registration relates to a participant who is not UK-based.
2. `teacher_catchment_iso_country_code` - This field identifies which non-UK country the participant has registered from. The API uses [ISO 3166 alpha-3 codes](https://www.iso.org/iso-3166-country-codes.html), three-letter codes published by the International Organization for Standardization (ISO) to represent countries, dependent territories, and special areas of geographical interest.
3. `teacher_catchment_country` - This field shows the text entered by the participant during their  NPQ online registration.

Example: A teacher from a country outside the UK uses the DfE’s digital service to register for an NPQ. The provider wants to identify the country the participant is registering from, so checks the API and finds:
* `"teacher_catchment": false` -  This means the participant is not UK-based.</li>
* `"teacher_catchment_iso_country_code": "FRA"` -  The provider investigates the result and identifies the participant is based in France.
* `"teacher_catchment_country": "France"` - The provider views the text the participant has entered in their online registration.


## 14th September 2022
The API will now return a helpful 422 error message to highlight invalid ECF or NPQ `course_identifier` entries.

Invalid entries include: spelling errors, unrecognised values not included in the schema, or a value included in the schema but not associated with the participant.

Example: When updating a participant record, an ECF provider enters an invalid `course_identifier`.

* A provider enters `"course_identifier": "ecf-induction"` when the participant is actually an `ecf-mentor`
* The API will check the `course_identifier` is valid against the `participant_id`
* This will identify whether or not the participant is registered for the given training
* The API will recognise that the `course_identifier` entered by the provider is invalid (as it should be `"course_identifier": "ecf-mentor"`)
* The API will return a 422 error message: `“The property '#/course_identifier' must be an available course to '#/participant_id'”`
* The provider will know to update the `course_identifier` entered

## 24th August 2022
ECF and NPQ lead providers can now trigger clawbacks of declarations which the DfE has paid to them.

To do this, use the void endpoint. This can be done for both API versions (1.0.0 and 2.0.0).

* A provider uses the void endpoint to void a declaration that was in the paid state.
* The state of the declaration will then become awaiting_clawback.
* On the next statement the DfE will then clawback the value of the declaration, including any associated uplift fee.

## 17th August 2022
Added non-standard ECF schedules to 2022 cohort:

* ecf-extended-september
* ecf-extended-january
* ecf-extended-april
* ecf-reduced-september
* ecf-reduced-january
* ecf-reduced-april
* ecf-replacement-september
* ecf-replacement-january
* ecf-replacement-april

These non-standard schedules start on the first day of the month of the given schedule name. For example ecf-extended-january starts on 1st January 2023. 

## 9th August 2022
Added `targeted_delivery_funding_eligibility` to NPQ applications. 

## 2nd August 2022

Removed the logic where the API would nullify the `email` field on the ECF and NPQ participant responses where the `status` is withdrawn. Now, where `status` is withdrawn, we will continue to display the participant’s `email`. Generally, the `status` will show withdrawn when a School Induction Tutor has withdrawn or “deleted” a participant in the schools user interface or “portal”. Where `email` was nullified, they will now be visible again.

## 24th June 2022
Added new declaration states `awaiting-clawback` and `clawed-back`

## 6th June 2022
* Added `cohort` to NPQ applications
* Added ability to filter by `cohort` on NPQ applications
* Added `ineligible_for_funding_reason` on NPQ applications
* Updated `eligible_for_funding` on NPQ applications to take previous accepted applications into consideration

## 11th May 2022
Added `yes_in_first_five_years` and `yes_over_five_years` to `headteacher_status` for NPQ applications

## 21st April 2022
Added `works_in_school`, `employer_name`, and `employment_role` to `NPQApplicationAttributes` API entities. Definitions available at `/api-reference/reference-v1.html#schema-npqapplication`. 

## 12th April 2022
When fetching participant declarations it will now return any declarations made by previous providers. This will allow you to determine what declarations you should be posting next.

## 8th March 2022
In the documentation `/api-reference/reference.html` has been moved to `/api-reference/reference-v1.html`

## 12th January 2022
`change-schedule` API endpoints now accept a `cohort` attribute in the request body. This defaults to the current cohort if it is not specified.

## 11th January 2022
Added new API endpoint `/api/v1/participants/ecf/{participant_id}/change-schedule`

## 7th January 2022
Added schedule with identifier `ecf-standard-april`

## 6th January 2022
* Schedule identifier has been renamed from `ecf-september-standard-2021` to `ecf-standard-september`
* Schedule identifier has been renamed from `ecf-january-standard-2021` to `ecf-standard-january`

## 3rd December 2021
Return JSON responses for 404 and 401 errors rather than `text/plain`

## 4th November 2021

* Added ability to defer an NPQ participant from a given course. `PUT /api/v1/participants/npq/{id}/defer`
* Added the new endpoint to defer an NPQ participant from a given course. `PUT /api/v1/participants/npq/{id}/defer`
* Added ability to resume an NPQ participant from a given course. `PUT /api/v1/participants/npq/{id}/resume`
* Added the new endpoint to resume an NPQ participant from a given course. `PUT /api/v1/participants/npq/{id}/resume`
* Added updated_at date to NPQ applications, NPQ participants, participants, and participant declarations (GET endpoints).

## 27th October 2021
Added created_at date to NPQ applications (GET endpoints).

## 25th October 2021
Add `employer` as possible option for NPQ `funding_choice`.

## 19th October 2021
* Added ability to withdraw an NPQ participant from a given course. `PUT /api/v1/participants/npq/{id}/withdraw`
* Added the new endpoint to withdraw an NPQ participant from a given course. `PUT /api/v1/participants/npq/{id}/withdraw`

The previous endpoint `PUT /api/v1/participants/npq/{id}/withdraw` is deprecated and will be remove in a later version of the API.

## 5th October 2021
pdate withdrawal and deferral reason codes.

Added created_at date to NPQ applications (GET endpoints).

## 29th September 2021
Add `GET /api/v1/participants/npq` endpoint.

## 22nd September 2021
Prevent changing schedule if the new schedule makes existing pending declaration invalid.

## 17th September 2021
Add `GET /api/v1/participants/ecf` endpoint.

## 16th September 2021

Share `pupil_premium_uplift` and `sparsity_uplift` values for ECF participants.

## 15th September 2021

Ability to void participant declarations.

## 10th September 2021

Ability to resume participants on a course.

## 9th September 2021
Added new action to retrieve a single participant declaration by ID.

## 8th September 2021
Ability to defer participants on a course.

## 7th September 2021
Standardise date filtering parameters between different api endpoints.

## 19th July 2021
Initial release of the NPQ usage guide.

## 1st July 2021
Initial release of the API reference documentation.