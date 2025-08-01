---
title: Release notes
weight: 8
---

# Release notes

If you have any questions or comments about these notes, please contact DfE via Slack or email.

## 24 June 2025

[#bug-fix]

### Declaration submission error for resumed participants resolved

We’ve fixed an issue that prevented lead providers from submitting training declarations for some participants who’d resumed training after being withdrawn. An incorrect error message said the declaration date must be before the withdrawal date.

Providers can now submit declarations for these participants as expected.

## 16 June 2025

[#new-feature #production-release #data-update]

Registration is now open for the 2025/26 intake of early career teachers and mentors, so we’ve added the schedules and contract data for this academic year to the production environment.

For more details, [view our guidance on changes for the 2025/26 academic year](/api-reference/changes-for-the-2025-2026-academic-year).

## 23 April 2025

[#sandbox-release #breaking-change]

We’ve updated the field value options in several v3 API test environment (sandbox) endpoints to reflect changes to the names we use for induction programme types. These changes will apply to all cohorts.

### Endpoints: `GET schools/ecf` and `GET schools/ecf/{id}`

**Field: `induction_programme_choice`**

| Original values | Updated values |
| -------------------- | ---------------------- |
| `core-induction-programme` and `design_our_own` | `school-led` |
| `full-induction-programme` and `school-funded-full-induction-programme` | `provider-led` |

The `no_early_career_teachers` and `not_yet_known` values stay the same.

### Endpoint: `PUT participants/ecf/{id}/withdraw`

**Field: `reason`**

| Original values | Updated values |
| -------------------- | ---------------------- |
| `school-left-fip` | `switched-to-school-led` |

The `left-teaching-profession`, `moved-school`, `mentor-no-longer-being-mentor` and `other` values are unchanged.

We’ve updated participant records across all cohorts that have previously used the `school-left-fip` value. This is not expected to affect how the endpoint functions. However, lead providers should resync with the API participants endpoint to ensure their systems integrate correctly. Records for withdrawn participants will surface the new value and have a modified `updated_at` timestamp.

To keep records up to date following these changes, lead providers should run regular full syncs across all cohorts using the `GET /api/v3/schools/ecf` endpoint. Providers will also need to perform a full sync when these changes go into production. This update aligns with the new `school-led` terminology we’ve introduced for the `induction_programme_choice` field in the `GET schools/ecf` and `GET schools/ecf/{id}` endpoints to replace the `core-induction-programme` and `diy` options.

We’ll contact providers directly to ensure their integrations can support the new values.

## 11 April 2025

[#cohort-closure #sandbox-release]

We’ve set up dummy data/contracts and milestones in the [API v3 test (sandbox) environment](https://sb.manage-training-for-early-career-teachers.education.gov.uk/) to support providers ahead of the closure of the 2022 ECF cohort at the end of July.

[View detailed guidance about the closure of the 2022 cohort](/api-reference/2022-cohort-closure-information-for-lead-providers)

### How we’ll handle participants who haven’t completed their training by 31 July

| Training status   | Post-2022 cohort closure |
| -------------------- | ---------------------- |
| Partially trained ECTs | We'll move these ECTs to the 2024 cohort if there’s evidence they require training during the 2025/26 academic year |
| Partially trained mentors | We will not transfer mentors to the 2024 cohort because they’re not eligible for further training. We’ll mark them as `completed` and update their `mentor_funding_end_date` |
| ECTs and mentors with no `eligible`, `payable`, `paid`, `awaiting_clawback` or `clawed_back` declarations | We’ll archive these participants. Providers should retire their records. If they’re re-registered in the 2025/26 academic year, they’ll have new IDs |

### Identifying ECTs who we’ve moved to the 2024 cohorts

To help providers identify these ECTs in the API v3 test environment, there’s a field in the `GET participant` API endpoints called `cohort_changed_after_payments_frozen`.

For ECTs who’ve moved cohorts, the field will have a `TRUE` value in it.

When calling the `GET participant` endpoint, the ECT’s `cohort` value will be 2024.

When calling the `GET participant-declarations` endpoint, the ECT will have historical declarations in their original cohort.

To simplify this, we recommend using the `cohort_changed_after_payments_frozen` field to identify the ECT.

We’ll also assign these ECTs to the `ecf-extended-september` schedule. This allows providers to submit any required declarations for the 2025/26 academic year.

<div class="govuk-inset-text">Unlike when we closed the 2021 cohort, mentors who started training in 2022 will not be able to be moved between frozen cohorts. This is because they will be marked as <code>completed</code>.</div>

### Provider checklist

We recommend providers use the dummy data we’ve set up in the test environment to:

- check their CRM to make sure they can handle an enrolment in a new cohort with declarations spanning across 2022 and 2024
- familiarise themselves with the `cohort_changed_after_payments_frozen` field in the `GET participant` endpoint response
- check they can see historically submitted declarations made in a previous cohort in the `GET participant-declarations` endpoint when using the cohort filter
- attempt some [future declarations](/api-reference/ecf/guidance/?#test-the-ability-to-submit-declarations-in-sandbox-ahead-of-time) and ensure they’re recorded and handled safely in their CRM

## 14 March 2025

[#new-feature #sandbox-release]

We've updated the test (sandbox) environment with all the `evidence_held` values lead providers will be able to use when they submit participant declarations for the 2025/26 intake of early career teachers (ECTs) and mentors.

These values represent the evidence lead providers hold to show participants have met the retention criteria for the current milestone period.

For 2025/26, every `declaration_type` will have its own `evidence_held` values (see tables). In previous years we’d applied the `training-event-attended`, `self-study-material-completed` and `other` values across all declaration types.

### Early career teachers

| Declaration type   | Evidence held values |
| -------------------- | ---------------------- |
| `started`   |  <ul class="govuk-list govuk-list--bullet"><li>`training-event-attended`</li> <li>`self-study-material-completed`</li> <li>`other`</li> <li>`materials-engaged-with-offline` (new value for 2025 onwards)</li></ul> |
| `retained-1` |  <ul class="govuk-list govuk-list--bullet"><li>`training-event-attended`</li> <li>`self-study-material-completed`</li> <li>`other`</li> <li>`materials-engaged-with-offline` (new value for 2025 onwards)</li></ul> |
| `retained-2` |  <ul class="govuk-list govuk-list--bullet"><li>`75-percent-engagement-met` (new value for 2025 onwards)</li> <li>`75-percent-engagement-met-reduced-induction` (new value for 2025 onwards)</li></ul> |
| `retained-3` |  <ul class="govuk-list govuk-list--bullet"><li>`training-event-attended`</li> <li>`self-study-material-completed`</li> <li>`other`</li> <li>`materials-engaged-with-offline` (new value for 2025 onwards)</li></ul> |
| `retained-4` |  <ul class="govuk-list govuk-list--bullet"><li>`training-event-attended`</li> <li>`self-study-material-completed`</li> <li>`other`</li> <li>`materials-engaged-with-offline` (new value for 2025 onwards)</li></ul> |
| `extended-1` |  <ul class="govuk-list govuk-list--bullet"><li>`training-event-attended`</li> <li>`self-study-material-completed`</li> <li>`other`</li> <li>`materials-engaged-with-offline` (new value for 2025 onwards)</li></ul> |
| `extended-2` |  <ul class="govuk-list govuk-list--bullet"><li>`training-event-attended`</li> <li>`self-study-material-completed`</li> <li>`other`</li> <li>`materials-engaged-with-offline` (new value for 2025 onwards)</li></ul> |
| `extended-3` |  <ul class="govuk-list govuk-list--bullet"><li>`training-event-attended`</li> <li>`self-study-material-completed`</li> <li>`other`</li> <li>`materials-engaged-with-offline` (new value for 2025 onwards)</li></ul> |
| `completed` |  <ul class="govuk-list govuk-list--bullet"><li>`75-percent-engagement-met` (new value for 2025 onwards)</li> <li>`75-percent-engagement-met-reduced-induction` (new value for 2025 onwards)</li> <li> `one-term-induction` (new value for 2025 onwards) </li></ul>|

### Mentors

| Declaration type   | Evidence held values |
| ------------- | ------------- |
| `started`   |  <ul class="govuk-list govuk-list--bullet"><li>`training-event-attended`</li> <li>`self-study-material-completed`</li> <li>`other`</li> <li>`materials-engaged-with-offline` (new value for 2025 onwards)</li></ul> |
| `completed` |  <ul class="govuk-list govuk-list--bullet"><li>`75-percent-engagement-met` (new value for 2025 onwards)</li> <li>`75-percent-engagement-met-reduced-induction` (new value for 2025 onwards)</li></ul> |

> New evidence types are not compatible with previous cohorts. If providers try using a new evidence type for an older cohort declaration, it will not work.

### What to test ahead of 2025 registration opening in June

We advise providers check their integrations can:

- support all new evidence types
- submit `one-term-induction` as `evidence_held` for `completed` ECT declarations
- supply evidence types for `started` declarations

## 3 March 2025

[#bug-fix]

We’ve resolved an issue in the API where a v2 declaration endpoint was inadvertently serving the v1 schema.

The fix updates the `POST` action to use the correct v2 schema.

The following declaration endpoint has been updated:

- `POST participant-declarations`

All endpoints now conform to the v2 schema specifications.

## 19 February 2025

[#new-feature #sandbox-release]

We’ve added the schedules and contract data for the 2025/26 intake of early career teachers (ECTs) and mentors to the test (sandbox) environment.

Lead providers can either add participants via the ECF interface or by using the seed data we’ve created. This will allow them to test the full end-to-end process and ensure smooth integration for any upcoming changes.

When registering participants in the test environment, providers must use the following date of birth if they want the 2025/26 ECTs to appear as eligible for funding:

- 25/1/1900

For mentors, use the following date of birth:

- 1/1/1900

### Changes to mentor declarations for the 2025/6 intake

We’ve removed the following declarations from the `POST participant-declarations` test environment endpoint for mentors starting in 2025/26:

- `retained-1`
- `retained-2`
- `retained-3`
- `retained-4`
- `extended-1`
- `extended-2`
- `extended-3`

This is because there’ll only be 2 mentor declarations from the 2025/26 academic year onwards, `started` and `completed`.

These changes align with the updated frameworks and payment guidelines shared with lead providers.

## 8 January 2025

[#bug-fix]

Lead providers getting participant declarations via the API endpoints will now see previous declarations attached to completed participants rather than just active participants.

Before this update they could only view previous declarations of participants who had an active <code>induction_status</code> and had not completed.

## 11 December 2024

We’ve fixed a bug that meant providers could see declarations from participants that were not relevant to them.  They would not have been able to identify the participants with this information.

Following the bug fix, providers can now only see relevant declarations.

## 11 December 2024

We’ve fixed a bug that caused the GET unfunded-mentors endpoint query to return incorrect or no longer valid email addresses in a small number of cases.

The fix we’ve made ensures the endpoint is now surfacing the most up-to-date email in the GET request’s response.

## 27 November 2024

We've launched a separate API for NPQs following a 3-month test phase. All NPQ data has been successfully migrated to the new environment, which means providers can no longer make NPQ-related calls from this API.

The base URL for this API continues to be:

- [https://manage-training-for-early-career-teachers.education.gov.uk/](https://manage-training-for-early-career-teachers.education.gov.uk/)

Providers can add the required API version and endpoint depending on what they want to do. For example, they’d add `/api/v3/participants/ecf` to the base URL if they wanted to retrieve data for multiple participants.

The endpoints documentation for each version of the API is also unchanged:

- [ECF API v1 documentation](https://manage-training-for-early-career-teachers.education.gov.uk/api-reference/reference-v1.html)
- [ECF API v2 documentation](https://manage-training-for-early-career-teachers.education.gov.uk/api-reference/reference-v2.html)
- [ECF API v3 documentation](https://manage-training-for-early-career-teachers.education.gov.uk/api-reference/reference-v3.html)

To ensure everything runs smoothly on the ECF side of things, we recommend providers take the following post-separation actions:

- check their integration supports ECF calls independently
- make sure all data flows and integrations continue to work as expected
- test internal processes to verify that data from the ECF environment is being handled appropriately
- conduct full data syncs within their allocated window so that data is up to date and accurate

Providers can contact us via their dedicated DfE Slack channel if they’ve got any suggestions or concerns.

## 2 September 2024

Providers can now see the new <code>mentor_ineligible_for_funding_reason</code> field in the API production environment's participant response bodies.

For full details about the field and the values it can display, read the <a href="/api-reference/release-notes.html#20-august-2024">release note we published</a> when we added this functionality to the test (sandbox) environment.

## 20 August 2024

We’ve added a field in the API sandbox environment’s participant response bodies to show why funding for a mentor’s training has ended.

This follows feedback from providers who want this information for record keeping.

The new field is called <code>mentor_ineligible_for_funding_reason</code>. It’ll display 3 possible values:

- <code>completed_declaration_received</code>. Providers will see this if the mentor has completed their mentor training
- <code>completed_during-early_roll_out</code>. This means the mentor completed their training during the pilot period of the ECF (Early Career Framework) programme, so is no longer eligible for funding
- <code>started_not_completed</code>. We’ll display this if 2 years has elapsed since a full-time mentor started training. After 2 years, they’re no longer eligible

We’d welcome feedback on this sandbox update before it goes into production. Providers can contact us via the usual Slack channel if they’ve got any suggestions or concerns.

## 13 August 2024

We’ve launched standalone API test environments so providers can manage ECF and NPQ data separately.

The merged data model that we’ve been running previously has proven challenging with bugs, unstable ID’s, issues with emails, and participants appearing and disappearing for providers.

The new approach with standalone APIs will stabilise the services and simplify the domain model. Operationally, providers will benefit from faster resolution times on issues for applicants and faster deployment on requested features and policy changes.

To help test the NPQ and ECF new world ahead of the full separation later in the autumn, we've launched ‘separation’ test environments with relevant seed data to replace the existing ‘sandboxes’.

To make requests in the new test environments, providers must use the bearer tokens that we’ve sent them via Galaxkey. The base URLs are:

- ECF test environment - [https://sp.manage-training-for-early-career-teachers.education.gov.uk](https://sp.manage-training-for-early-career-teachers.education.gov.uk)
- NPQ test environment - [https://npq-registration-separation-web.teacherservices.cloud](https://npq-registration-separation-web.teacherservices.cloud)

Providers can add the required API version and endpoint depending on what they want to test. For example, they’d add /api/v3/npq-applications to the NPQ test environment URL if they want to retrieve multiple applications.

We’ve also created documentation for the new separation environment endpoints:

- [ECF API v1 documentation](https://sp.manage-training-for-early-career-teachers.education.gov.uk/api-reference/reference-v1.html)
- [ECF API v2 documentation](https://sp.manage-training-for-early-career-teachers.education.gov.uk/api-reference/reference-v2.html)
- [ECF API v3 documentation](https://sp.manage-training-for-early-career-teachers.education.gov.uk/api-reference/reference-v3.html)
- [NPQ API v1 documentation](https://npq-registration-separation-web.teacherservices.cloud/api/docs/v1)
- [NPQ API v2 documentation](https://npq-registration-separation-web.teacherservices.cloud/api/docs/v2)
- [NPQ API v3 documentation](https://npq-registration-separation-web.teacherservices.cloud/api/docs/v3)

The existing sandbox environments will remain accessible and unchanged to allow continued testing on the current API setup.

## 1 July 2024

Registration has opened for the 2024/25 intake of NPQ participant applications, so we’ve added the following to the production environment:

- the 2024/25 NPQ data and schedules
- functionality which enables providers to set whether NPQ applicants are going to have their training funded by DfE
- the new special education needs coordinator (SENCO) NPQ

See the [14 June release note](/api-reference/release-notes.html#14-june-2024) for more details about the funded training functionality and SENCO NPQ.

## 28 June 2024

We’ve added some new features to help providers ahead of the closure of the funding contract for the 2021 cohort on 31 July.

The main impact will be ECTs and mentors with partial declarations currently assigned to the 2021 cohort being moved to the 2024 cohort.

Because these ECTs and mentors are automatically shifted from a standard to an extended schedule, we’re allowing providers to change their schedules if necessary, using the existing [change-schedule](/api-reference/reference-v3.html#api-v3-participants-ecf-id-change-schedule-put) endpoint.

Providers can also temporarily move participants back to the 2021 cohort if they need to make any final declarations before it closes. They must be returned to the 2024 cohort to start making submissions against that year.

Note that the schedule and cohort cannot be changed when a migrated participant is in the 2024 cohort if there are existing declarations in any of the following states:

- submitted
- eligible
- payable
- paid

However, you can make changes in the 2021 cohort where participants already have declarations in these statuses.

## 25 June 2024

Registration is now open for the 2024/25 intake of early career teachers and mentors, so we’ve added the schedules and contract data for this academic year to the production environment.

## 18 June 2024

From today, schools have started moving ECTs and mentors with partial declarations currently assigned to the 2021 cohort to the 2024 cohort.

This is because we’re closing the funding contract for the 2021 cohort at the end of July.

Providers will be able to identify participants who’ve been moved by the new `cohort_changed_after_payments_frozen` attribute to the [participant response](/api-reference/reference-v3.html?#api-v3-participants-ecf-get-responses-examples) in the API v3 production environment. The value shown for these participants will be `true`.

Providers will no longer be able to submit or void declarations for the 2021 cohort after the contract closes on 31 July.

## 14 June 2024

We’ve added the new special educational needs coordinator (SENCO) NPQ to the [test (sandbox) environment](https://sb.manage-training-for-early-career-teachers.education.gov.uk/) for the 2024 cohort.

The new course’s identifier is `npq-senco`.

Providers can access this within the sandbox environment for testing. Functionality will be the same as the other existing NPQ courses.

We’ll notify providers when this new NPQ is available in the production environment.

We're trialing new functionality in the API test ([sandbox](https://sb.manage-training-for-early-career-teachers.education.gov.uk/)) environment which will enable providers to set whether NPQ applicants are going to have their training funded by DfE.

This is because from the 2024/25 academic year onwards there'll be a set maximum number of places each provider can offer per NPQ that DfE will pay for.

Providers using all versions of the API can set the new `funded_place` field in the 'Accept an application' request body to true or false. They will also see the `funded_place` field in the following endpoint response bodies:

- 'View all applications'

- 'View a specific application'

- 'View all participant data'

- 'View a single participant's data'

Providers who need to update a participant's funding information after an application has been accepted can do so via the 'Change funded place' endpoint.

## 13 June 2024

We’ve fixed an issue with the API v3 NPQ participants endpoint where performing a full sync with pagination resulted in IDs beings omitted. No other endpoint was affected.

The NPQ participants endpoint and the pagination will now return all users in the NPQ GET participants endpoint.

Providers are recommended to perform a full re-sync at the earliest convenience to retrieve all participant records.

## 10 June 2024

On 31 July we’re closing the funding contract for the 2021 cohort.

This means ECTs and mentors with partial declarations currently assigned to the 2021 cohort will be moved to the 2024 cohort.

Providers can now test the functionality for the migration of these ECTs and mentors.
Participants who’ve moved can be identified by the new `cohort_changed_after_payments_frozen` attribute to the participant response in the [API v3 test (sandbox) environment](https://sb.manage-training-for-early-career-teachers.education.gov.uk/). The value shown for these participants will be `true`.

Providers will be able to test future declaration submissions in the 2024 cohort but can no longer submit or void declarations for 2021 after the contract has closed.

We’d welcome feedback on this sandbox update before it goes into production.

## 5 June 2024

We're addressing a potential confusion for providers filtering participant declarations by cohort.

Currently, filtering by a participant's current cohort (for example, 2022) returns all their declarations, even those made when the participant was in an earlier cohort (for example, 2021).

For instance, if a participant is in the 2022 cohort, but has declarations in both 2021 and 2022, all declarations are returned when filtering by 2022, and none when filtering by 2021.

Going forward, we’ll now return only the declarations made during the specified cohort. For example:

- filtering by 2021 will return only the declarations made while a participant was in the 2021 cohort
- filtering by 2022 will return only the declarations made while a participant was in the 2022 cohort

We’ve released this in the API v3 Live environment.

## 24 May 2024

We’ve added the schedules and contract data for the 2024/25 intake of early career teachers and mentors to the [test (sandbox) environment](https://sb.manage-training-for-early-career-teachers.education.gov.uk/).

Providers can either add participants via the ECF interface or by using the seed data we’ve created. When registering participants in the test environment, providers must use the following date of birth if they want the 2024/25 ECTs to appear as eligible for funding:

- 24/1/1900

For mentors, use the following date of birth:

- 1/1/1900

Providers can also sign in to the [sandbox environment](https://sb.manage-training-for-early-career-teachers.education.gov.uk/users/sign_in) as school induction tutors, where dynamic scenarios such as transfers can be simulated.

As always, we’d welcome feedback on this sandbox update before it goes into production.

## 8 March 2024

Lead providers can now use the new `mentor_funding_end_date` field in the Live environment’s [ECF participant endpoint](/api-reference/reference-v3.html#api-v3-participants-ecf-get).

Further details are available in the release note of [4 March 2024](/api-reference/release-notes.html#4-march-2024).

## 4 March 2024

We’ve found and fixed a bug that meant ‘participant IDs’ had been wrongly changed for a very small subset of ECF and NPQ participants with multiple profiles. We’ve now switched all users to the right profile IDs.

## 4 March 2024

We're trialing new functionality in the API v3 sandbox which surfaces the `mentor_funding_end_date` field in the [ ECF participant endpoint](/api-reference/reference-v3.html#api-v3-participants-ecf-get).

When a declaration is submitted for a mentor the completed date will equal the declaration date. When a declaration is voided the completed date will be cleared. Completed dates for early roll-out mentors will be set to 19 April 2021 regardless of any completed declarations.

We'd welcome feedback on this sandbox update before it goes into production.

## 16 February 2024

We’ve found and fixed a bug that meant for a small number of NPQ applications the value in the `itt_provider` field was incorrectly set, so was not showing the name of the provider.

The full legal name of the initial teacher training provider can now be seen on all applications impacted by this bug.

## 6 February 2024

We’ve done an update to ensure that early career teacher (ECT) participant records only ever appear in one cohort.

Some providers had found it confusing because participants who’d moved cohort were appearing multiple times when they filtered by cohort in the ‘GET participants’ endpoint.

Training providers will now only see the ECT in the latest cohort they’ve been assigned to.

## 30 January 2024

We’ve fixed an issue with merging duplicate user accounts that meant existing declarations were not being redirected to the newly merged account correctly.

Participant records in merged accounts will now point to the right declarations in the [ECF](/api-reference/reference-v3.html#api-v3-participants-ecf-get) and [NPQ](/api-reference/reference-v3.html#api-v3-participants-npq-get) GET participant endpoints.

This will ensure that all participant declarations are consistent.

## 17 January 2024

We’ve fixed a bug that had prevented some providers from changing schedules for participants they are training who have not been registered in a default partnership. In such instances they’d have seen the following 422 error message:

* ‘You cannot change a participant to this cohort as you do not have a partnership with the school for the cohort. Contact the DfE for assistance.’

This error message should now only apply where a lead provider is attempting to the use the [change schedule endpoint](/api-reference/reference-v3.html#api-v3-participants-ecf-id-change-schedule-put) to change the participant's cohort.

## 28 November 2023

We've fixed a bug that meant some providers were having issues finding unfunded mentor IDs when using the `updated_at` filter on the [GET unfunded mentors endpoint](/api-reference/reference-v3.html#api-v3-unfunded-mentors-ecf-get).

The `updated_at` value of an unfunded mentor now gets touched when the mentor is linked to an ECT.

An API call to the unfunded mentors endpoint filtered for any updates once the link has been made will return the unfunded mentor in the response.

## 9 November 2023

We're trialing new functionality in the API v3 sandbox which allows lead providers to add a participant's schedule when accepting NPQ applications.

We've added the optional `schedule-identifier` field on the [NPQ accept an application request body](/api-reference/npq/guidance.html#example-request-body).

This will prevent providers having to make manual changes if a participant has been defaulted to the wrong schedule.

We'd welcome feedback on this sandbox update before it goes into production.

## 6 November 2023

Lead providers can now use the new `participant_id_changes` features in the Live environment.

Further detail on the change is available in the release note of [6 October 2023](/api-reference/release-notes.html#6-october-2023).

## 2 November 2023

The DfE has released a fix for an issue which affected NPQ only providers using the v3 declarations endpoints. Some providers reported receiving 403 errors when attempting to POST or GET declarations. The issue was limited to v3. The fix has been released to sandbox and production environments.

The fix also addresses an issue with the [cohort filter](/api-reference/reference-v3.html#schema-participantdeclarationsfilter), which is available for the declarations endpoint. Providers using the filter should now see that the response only returns NPQ and ECF declarations in the cohort specified. Previously, the filtering was inconsistent for NPQ declarations. The fix applies to production and sandbox environments.

## 30 October 2023

Lead providers will now see a 422 error code if a `completed` declaration outcome fails. In such instances, you'll be prompted to contact us for support.
## 17 October 2023

Lead providers can now test the new `participant_id_changes` feature in the sandbox.

The DfE welcomes feedback and intends to deploy the change to the production environment as soon as possible.

Further detail on the change is available in the release note of [6 October 2023](/api-reference/release-notes.html#6-october-2023).

## 16 October 2023

We've removed the `started-in-error` option from the [ECFWithdrawal schemas](/api-reference/reference-v3.html#schema-ecfwithdrawal) in all versions of the API.

Note that NPQ participants can still be withdrawn for this reason.

## 10 October 2023

Lead providers integrated with v3 of the API can now view details of ECTs that have completed their induction.

We've added a new field, `induction_end_date`, to [ECFEnrolment](/api-reference/reference-v3.html#schema-ecfenrolment). We populate the field with data gathered about the date an ECT completed their induction from the Database of Qualified Teachers (DQT).

We check the DQT on a daily basis for data about induction completion. We'll update a participant's records when we confirm they've completed their induction. Lead providers can use the [`updated_since` filter on the GET participants endpoint](/api-reference/reference-v3.html#schema-ecfparticipantfilter) to check for this kind of update.

Lead providers can use the field to identify participants that have completed their induction, and which may need to be placed on a [reduced schedule](/api-reference/ecf/schedules-and-milestone-dates.html#reduced-schedule).

## 9 October 2023

We've released a change to the `updated_at` functionality of the [ECFPartnershipAttributes](/api-reference/reference-v3.html#schema-ecfpartnershipattributes).

Now, when a user (for example, a school induction tutor) challenges a partnership, the date and time of this change will populate the `updated_at` field of the partnership.

In this way, providers may rely on the `updated_since` filter to identify if the partnership has been challenged since their most recent call to the API.

## 6 October 2023

We’ve added experimental fields to the API v3 sandbox environment to make it simpler for lead providers to identify and manage deduped participants.

We’ve [previously advised](/api-reference/release-notes.html#15-march-2023) of the possibility that participants may be registered as duplicates with multiple participant_ids.

Where we identify duplicates, we'll fix the error by ‘retiring’ one of the participant IDs, then associating all records and data under the remaining ID. To date, when this occurred, the DfE has informed providers of changes via CSVs.

We’re now proposing that lead providers may manage these limited changes using some new API v3 functionality including:

* a new `participant_id_changes` nested structure added to the [ECFEnrolment](/api-reference/reference-v3.html#schema-ecfenrolment) and [NPQEnrolment](/api-reference/reference-v3.html#schema-npqenrolment) schemas, which would each contain a `from_participant_id` and a `to_participant_id` string fields, as well a `changed_at` date value
* a new filter for the various GET participant endpoints, so lead providers can search by a participant_id to check if it has changed, which will return the participant including their changed id. For example, **GET** `api/v3/participants/ecf?filter[from_participant_id]={your_id}`

We welcome feedback on these changes and intends to release them to the sandbox and production as soon as possible. We'll provide a release note at each stage.

## 2 October 2023

We’ve added the new NPQ in leading primary mathematics to the production environment.

The new course’s identifier is `npq-leading-primary-mathematics`. Functionality is the same as the other existing NPQ courses.

Providers should ensure that any participants they accept for this course are on the correct schedule.

## 13 September 2023

We’ve added the new NPQ in leading primary mathematics to the sandbox environment.

The new course’s identifier is `npq-leading-primary-mathematics`. Providers can access this within the sandbox environment for testing. Functionality will be the same as the other existing NPQ courses.

Providers will be notified ahead of this new NPQ becoming available in the production environment.

## 6 September 2023

### Planned API downtime on 14 September

The API will be unavailable from 6pm to 9pm on Thursday 14 September while we perform planned maintenance.

Providers should pause API calls during this time. You’ll be able to start using the API again from 9pm.

## 5 September 2023

### New sandbox URL

We will be changing the sandbox URL to [https://sb.manage-training-for-early-career-teachers.education.gov.uk/](https://sb.manage-training-for-early-career-teachers.education.gov.uk/) on Thursday 7 September.

The sandbox environment will be unavailable between 5pm and 7pm on 7 September while we make this change.

Providers should:

* pause testing between 5pm and 7pm on 7 September
* update their base URL for their integrations once the sandbox environment becomes available again to avoid any data loss

## 24 August 2023

Lead providers can now submit 'extended declarations' for ECTs that are on extended schedules in production. The change applies to all versions of the API. Previously, lead providers could only test the new functionality in the [sandbox environment](/api-reference/release-notes.html#17-august-2023).

There is [guidance available for providers in the API documentation](/api-reference/ecf/schedules-and-milestone-dates.html#extended-schedules). Please note that while there are currently only three extended declarations, the number of extended declarations a provider may need to submit is not limited in the contract. The DfE may add additional extended declarations should the need arise.

## 17 August 2023

Lead providers can now submit 'extended declarations' for ECTs that are on extended schedules in the sandbox environment. Providers may not submit extended declarations for mentors.

Qualifying ECTs will have had their induction extended as a result of having not yet met the Teachers' standards, and need additional support to meet the standards. These ECTs must be placed onto one of the available ['extended schedules'](/api-reference/ecf/schedules-and-milestone-dates.html#extended-schedules) for ECF.

Providers may submit an extended declaration (subject to meeting the engagement criteria) for each extended term until the ECT has completed their induction, up to a maximum of three extensions. On completing induction, the provider should submit a completion declaration for the final term.

For further details about how and when to use these declaration types, providers should refer to the ECF payment guidance issued by their contract manager.

Providers may submit extended declarations using the following values in the `declaration_type` field on the [participant declaration request body](/api-reference/reference-v3.html#schema-participantdeclarationrequest):

- extended-1
- extended-2
- extended-3

Providers will be notified ahead of this functionality becoming available in the production environment.

## 10 August 2023

Lead providers can now ‘resume’ NPQ and ECF participants they've previously withdrawn.

Lead providers should use the relevant [ecf](/api-reference/reference-v3.html#api-v3-participants-ecf-id-resume-put) or [npq](/api-reference/reference-v3.html#api-v3-participants-npq-id-resume-put) resume endpoints to change a given participant’s `training_status` from withdrawn to active.

The DfE will monitor levels of withdrawn participants that have been resumed.

## 31 July 2023

Lead Providers can now change the cohort of an ECF participant, providing that:

- the lead provider has a partnership with the school in the new cohort they want to move the participant into; and
- any declarations the provider may have made for the participant have been `voided` or `clawed_back`

Providers may change an ECF participant's cohort using the [change-schedule endpoint](/api-reference/reference-v3.html#api-v3-participants-ecf-id-change-schedule-put).

If a lead provider has no partnership with a school for cohort 2022 and tries to change a participant from 2023 to 2022 cohort, then the API will return an error: `You cannot change a participant to this cohort as you do not have a partnership with the school for the cohort. Contact the DfE for assistance.`

If the participant has any declarations which are in certain states - submitted, eligible, payable, paid - then the API will also return an error: `Changing schedule would invalidate existing declarations. Please void them first.`

## 20 July 2023

The DfE has released a fix for a bug affecting the POST partnerships endpoint. Previously, providers were unable to report, via the API, a partnership with a delivery partner where a partnership based on the same details had been challenged by the induction tutor. This issue no longer applies.

The DfE has also released a fix to an issue with the user interface lead providers can access to view details on the service about their partnerships. Some lead providers may have seen more than one partnership reported for a school in the same cohort. This issue has also been fixed.

## 13 July 2023

Providers may now filter outcomes by created_since date. For example:

* GET /api/v1/participants/npq/outcomes?filter[created_since]=2023-04-17T23:11:18Z

The change applies to all API versions.

Providers can now filter ECF and NPQ participants by training_status, for example:

* GET /api/v3/participants/ecf?filter[training_status]=deferred
* GET /api/v3/participants/npq?filter[training_status]=active

The filter is optional and only applies to v3 of the API. More detail is available in the [NPQ](/api-reference/reference-v3.html#api-v3-participants-npq-get) and [ECF](/api-reference/reference-v3.html#api-v3-participants-ecf-get) specifications.

## 12 July 2023

DfE has changed functionality around the endpoint `PUT /api/v1/participants/npq/{id}/defer`

Providers may not defer an NPQ participant unless the participant has at least a `started` declaration and which has not been voided. This is in line with the NPQ withdrawal endpoint and contractual requirements. The change applies to all versions of the API.

If a provider wishes to defer a participant without a started declaration then they should contact the DfE which can undo the application.

## 7 July 2023

Providers can now see the name of the lead provider which submitted a given declaration. Providers can find more detail on the new attribute `lead_provider_name` in the [v3 specification](/api-reference/reference-v3.html#schema-participantdeclarationresponse).

Providers may see declarations submitted by another provider where an ECF participant has transferred. A provider may not void a declaration submitted by another provider.

The change only applies to v3 and will apply to ECF and NPQ declarations.

## 5 July 2023

The DfE has updated error messages for several endpoints. There has been no change to functionality, error codes, or the scenarios which result in an error. The changes only involve an update to the `detail` part of the error message.

## 3 July 2023

The DfE has added a new possible value to the NPQ withdrawal_reason field.

When submitting a withdrawal request for an NPQ participant, providers may now include the following value:

* `expected-commitment-unclear`

Providers can view details about NPQ participant [withdrawal request schema](/api-reference/reference-v1.html#schema-npqparticipantwithdrawattributes) in the API specification.

## 2 June 2023

Providers can now make calls to API 3.0.0 in the production environment.

Based on feedback from testing in the sandbox, the following updates have been made:

* API v3 endpoints will order responses by `created_at` by default
* an `updated_at` attribute has been added to the ECF statement response
* `updated_since` filter parameters can be used when [viewing ECF statements](/api-reference/ecf/guidance.html#view-financial-statement-payment-dates) and [viewing ECF schools](/api-reference/ecf/guidance.html#find-schools-delivering-ecf-based-training-in-a-given-cohort)
* an `id` parameter has been added to the [endpoint specifications for ECF schools](/api-reference/reference-v3.html#api-v3-schools-ecf-id-get)
* the formatting of the `completion_date` attribute has amended to follow ISO 8601 format in the [specifications for NPQ outcomes](/api-reference/reference-v3.html#schema-npqoutcomeattributes)

To improve sandbox performance, queries underpinning key endpoints have been optimised. Providers should notice a reduction in slower response times when testing in the sandbox.

**Note:**

* providers are not expected to integrate with API v3 if taking part in the upcoming ECF pilot. The DfE will continue to support v1 and v2 of the API until further notice
* if providers do wish to integrate with v3 and would like to sync historical records, providers must coordinate with the DfE to manage load on the service

Providers are invited to give feedback on the API. Feedback can include, for example, the addition of new filters or functionality.

## 1 June 2023

School induction tutors are now able to register ECT as mentors at their school. To see how this affects data given via API v3, providers can test this induction tutor functionality in the sandbox.

Note, induction tutors are not yet able to register ECTs as mentors at different schools.

[Watch a demonstration of how to register an ECT as a mentor.](https://www.loom.com/share/7f45563f846a46aba30c713f1b0a7cce)

[View API v3 specifications for the ‘nested’ participant response.](/api-reference/reference-v3.html#api-v3-participants-ecf-get)

See the [13th April 2023 release note](/api-reference/release-notes.html#13th-april-2023) for details on how the API handles ECT-mentors depending on provider integrations with API versions 1 or 2 and version 3.

## 19 May 2023

Providers can now test API v3.0.0.0. integrations in the sandbox environment. Additional seed data has been added to sandbox to enable the testing of new scenarios.

Feedback from providers is invited via the usual channels. All feedback will be considered ahead API v3 release to production environment.

Changes to the [API v3 spec](/api-reference/reference-v3.html) have been implemented since the original draft was shared. Based on provider feedback and continual improvement, these include:

* the addition of a URN filter for when providers [find schools delivering ECF-based training in a given cohort](/api-reference/reference-v3.html#api-v3-schools-ecf-get)

* pagination parameter functionality on multiple GET endpoints which, for example, do not include an `{id}` parameter

* the addition of a date attribute which allows providers to view and update when a participant has deferred [from their ECF-based training](/api-reference/reference-v3.html#schema-ecfdeferral) or [from their NPQ course](/api-reference/reference-v3.html#schema-npqdeferral)

* an update on where participant email addresses are included within participant responses to reduce confusion if, for example, a participant uses different email addresses when registering as an ECT and mentor

* the removal of the `validation_status` attribute from the [ECF participant response](/api-reference/reference-v3.html#schema-ecfparticipant). New attribute options will be tested and added at a later stage, to meet provider and delivery partner needs

### Test dynamic scenarios

Providers will also be able to [sign into the sandbox environment](https://sb.manage-training-for-early-career-teachers.education.gov.uk/users/sign_in) as school induction tutors. Scenarios, such as transfers, can be simulated. Providers will be contacted shortly with login instructions.

**Note,** when registering participants in the sandbox environment, providers must use the following dates of birth if they want to the participants to appear as **eligible for funding**:

* ECT, 2022 cohort – date of birth 22/1/1900
* ECT, 2023 cohort – date of birth 23/1/1900
* Mentor, 2023 cohort – date of birth 1/1/1900

### Watch video demos

Watch videos on how to test the behaviour of the API in the scenario where:

* [a participant is leaving a school, transferring to another](https://www.loom.com/share/7513dd3980814230bf4221e3976a2033)
* [a participant is joining a school, transferring from another]( https://www.loom.com/share/d4d8a9f8f7254f0ca36ad63028ba4178)
* [a school induction tutor assigns an ECT to an ‘unfunded mentor’](https://www.loom.com/share/7c17218248234a23aec5591cc74d0adb)
* [a school induction tutor confirms a partnership will continue into the next cohort]( https://www.loom.com/share/bfbad349fe2c470d89e6949d78e43fc8)
* [a school induction tutor challenges an existing partnership]( https://www.loom.com/share/af0ad15980cf434d8361da5633d730c6)

## 15 May 2023

To support providers with their integrations with API v3.0.0.0, the API guidance has been updated.

Original instruction has been replaced with the following guidance:

* [About the API](/api-reference) - an overview of the API’s core functionality and version control
* [Get started](/api-reference/get-started) - instruction on how to connect to the API
* [ECF-based training management](/api-reference/ecf) - an overview key ECF concepts, instruction on new and existing endpoints, and schedule dates
* [NPQ course management](/api-reference/npq) - an overview of key NPQ concepts, instruction on new and existing endpoints, and schedule identifiers

Providers are invited to feedback ahead of the API v3 release to the production environment. Updates to the guidance will be made as needed.

Note, API v3.0.0.0 is not yet available in either sandbox or production environments.

## 13 April 2023

To enable the scenario where a participant needs to be registered as a mentor after having already been trained as an ECT by a given provider, a new `training_record_id` attribute has been added to the [ECF participant schema](/api-reference/reference-v1.html#schema-ecfparticipant).

The `training_record_id` value will be unique to each registration that a participant has for ECF-based training, as either an ECT or mentor.

Induction tutors have not yet been able to register participants as mentors if they were already registered as ECTs. Given the likely scenario that ECTs will go on to become mentors, the `training_record_id` attribute will soon allow the service to recognise and differentiate registrations. Note, DfE does not expect induction tutors to begin registering ECTs as mentors until June.

For the moment, we have added examples to provider sandbox environments:

* when using the endpoint GET /api/v1/participants/ecf, providers will receive an API response with all the ECF-based training registrations. Where a given participant is registered as both an ECT and a mentor, they will see multiple responses that each have the same participant_id, but which have unique `training_record_ids` for the mentor and ECT response
* when using the endpoint GET /api/v1/participants/ecf/{id}, providers will only receive a single response for a given participant. Where a given participant is registered as both an ECT and a mentor, this will be associated with the participant’s ECT registration, not their mentor registration. Note, when API version 3.0.0 is released and integrated with, providers will receive all registrations for the participant ‘nested’ under the relevant `training_record_id`

Specifications for the `‘nested’ participant response` can be found in the [draft API version 3.0.0. documentation](/api-reference/reference-v3.html#api-v3-participants-ecf-get).

Note, if the DfE has been in touch regarding consolidating inconsistent participant_ids (see the [release note on 15 March 2023](/api-reference/release-notes.html#15th-march-2023)), the `training_record_id` would not change as it is unique to a registration.

## 15 March 2023

Providers will see reduced errors and inconsistencies associated with `participant_id` values.

Providers have previously reported seeing different `participant_id` values associated with a single participant. For example, an NPQ provider may have seen a `participant_id` value of XXX via the applications endpoint, but when submitting a declaration for the same participant, the response body returned a `participant_id` value of YYY.

These types of inconsistencies were appearing because the API was exposing the underpinning ECF and NPQ programme data models. The DfE has now updated the API logic to align `participant_id` values across various API endpoints and prevent related issues.

Note, providers may need to update IDs held on their systems. The DfE will contact providers with further instruction if:

- they need to reconcile multiple `participant_ids` into a single true `participant_id`
- they need to replace a `participant_id` as a result of this API release

While the expected volume of future instances is expected to be very low (where single participants are registered with multiple `participant_ids`), providers who identify issues should contact the DfE via existing support channels. The DfE will fix errors by 'retiring' one of the IDs, then associating all records and data under the remaining ID. The DfE will inform providers as to which `participant_id` they will need to record on their systems.

## 14 March 2023

DfE has updated the definition of the cohort attribute in the API guidance and schema definitions for ECF and NPQ. Note, this update is limited to definitions and guidance. There has been no change to API functionality or business rules.

This update ensures API documentation is properly aligned with contractual terms and the way the attribute is used and understood by providers.

Cohorts are now defined as the value indicating which call-off contract funds a given participant’s training. For example, 2021 indicates a participant that has started, or will start, their funded training in the 2021/22 academic year.

[Read guidance around cohorts for ECF providers](/api-reference/ecf-usage.html#notifying-of-schedule-ecf-cohort-attribute)

[Read guidance around cohorts for NPQ providers](/api-reference/npq-usage.html#notifying-of-schedule-npq-cohort-attribute)

## 28 February 2023

Providers can now review updated draft documentation for API version 3.0.0. Presentations and further feedback sessions on the proposed changes will be arranged with providers directly.

Note, providers are not yet able to use API version 3.0.0 in any environment. Functionality should be available in the sandbox environment in May 2023, and in the live production environment in June 2023.

Initial API draft documentation was shared with providers in Summer 2022. Following workshops with providers in November and December, DfE have gathered insights and incorporated feedback into the newly published draft documentation.

### Important changes to be aware of for API version 3.0.0

#### New endpoints will become available

To address feedback from providers, DfE will avoid adding new attributes to existing endpoints (and their response bodies) where possible, and will instead create new endpoints to meet provider needs.

#### ECF providers will receive nested participant responses

To support the need to see participant details for those that train as an ECT and/then as a mentor with the same provider, the API will present nested data for ECF participant responses.

#### ECF providers will be able to view transfer details

New endpoints will allow providers to view details for any participants (who they train or will train) who have transferred to new schools. Existing ECF participant endpoints will present a `participant_status` attribute which will identify participants that are leaving or joining.

#### ECF providers will be able to view details for ‘unfunded’ mentors

New endpoints will allow providers to view details for mentors linked to ECTs, but who are not eligible for DfE funding.

#### ECF providers will be able to identify schools they could partner with

New endpoints will allow providers to view details for schools they could contact to partner with.

#### ECF and NPQ providers will see new attributes when using declaration endpoints

The API will continue to support NPQ and ECF declarations via existing endpoints. Providers may therefore see `null` values for attributes that do not apply to their declaration’s course type. For example, the `delivery_partner_id` attribute for an NPQ declaration will always be `null`.

## 24 February 2023

When [submitting completed ECF declarations](/api-reference/ecf-usage.html#declaring-that-an-ecf-participant-has-completed-their-course), providers should note that `evidence_held` is a mandatory attribute and must be included in the request body. API documentation has been updated in line with contractual requirements.

Providers can only submit accepted `evidence_held` values. These signify the type of evidence held by a provider to demonstrate that a participant has met the retention criteria for the milestone period. The accepted values are:

* `"evidence_held": training-event-attended`
* `"evidence_held": self-study-material-completed`
* `"evidence_held": other`

Note, other mandatory attributes to include in the request body for completed ECF declaration submissions are `participant_id`, `declaration_type`, `declaration_date` and `course_identifier`.

## 23 February 2023

Initial teacher training (ITT) lead mentors who are not employed by schools are now eligible for DfE funding.

During their registration journey, applicants for the leading teacher development NPQ will enter data to identify themselves as ITT lead mentors and validate their funding eligibility.

Providers will see two new data attributes when viewing application data via the endpoint `GET /api/v1/npq-applications`:

* `lead_mentor` - This signifies whether an applicant is a lead mentor (`"lead_mentor": true`) or not (`"lead_mentor": false`)
* `itt_provider` - This will show the name of the accredited provider

Note, unlike other NPQ applicants, ITT lead mentors do not need to enter some information on their registration journey. The following attributes will have null values:

* `employer_name`
* `employment_role`
* `school_urn`

## 26 January 2023

Providers are now able to submit, view and update NPQ participant outcomes in the production environment.

When an NPQ participant completes their course, their final assessment will determine a pass or fail outcome. Providers are required to notify DfE of outcomes, and provide updated outcomes as required.

DfE will then notify the TRA who will issue certificates to any participants who have passed their NPQ course.

Note, this functionality became available in the sandbox environment on 16 January 2023. Read more detailed guidance below on:

* [Submitting NPQ outcomes in 'completed' declarations](#submitting-npq-outcomes)
* [Updating NPQ outcomes](#updating-npq-outcomes)
* [Viewing NPQ outcomes for participants](#viewing-npq-outcomes)

## 16 January 2023

Providers are now able to submit, view and update NPQ participant outcomes in the sandbox environment. Note, providers will be notified ahead of this functionality becoming available in the production environment.

When an NPQ participant completes their course, their final assessment will determine a pass or fail outcome. Providers are now required to notify DfE of outcomes as part of `completed` declaration submissions, and provide updated outcomes as required.

The DfE will then notify the TRA who will issue certificates to any participants who have passed their NPQ course.

### Submitting NPQ outcomes in 'completed' declarations

Providers must include participant outcomes as part of NPQ `completed` declaration submissions. The mandatory `has_passed` attribute must be included as part of the request body for the following endpoint:

```
POST /api/v1/participant-declarations
```

Providers can submit `has_passed` values as follows:

* `"has_passed": true` - this signifies a participant has passed their course
* `"has_passed": false` - this signifies a participant has failed their course

`completed` declaration submissions which do not include outcomes will be rejected as invalid requests.

If providers void `completed` declarations where a participant had passed assessment (`"has_passed": true`), then this outcome will also be retracted and the participants will be notified.

### Updating NPQ outcomes

Providers can update participant outcomes (defined by the `state` attribute) if they made an error in the data originally submitted, or if the participant fails, retakes and goes on to pass their assessment.

Providers should include updated values for the NPQ `state` and `completion_date`, as well as the explicit `course_identifier` for the new endpoint:

```
POST /api/v1/participants/npq/{participant_id}/outcomes
```

Providers can submit `state` values as follows:

* `"state": passed` - this will update the record to signify a participant has passed their course
* `"state": failed` - this will update the record to signify a participant has failed their course

### Viewing NPQ outcomes for all participants

Providers can view all outcomes submitted for NPQ participants by using the following endpoints. Outcomes will be defined in the responses by the state attribute with values including:

* `"state": passed` - this signifies a participant has passed their course
* `"state": failed` - this signifies a participant has failed their course
* `"state": voided` - this signifies a `completed` declaration has since been voided and therefore the associated outcome retracted

Providers can view outcomes for all NPQ participants by using the new endpoint:

```
GET /api/v1/participants/npq/outcomes
```

Providers can view outcomes for a specific NPQ participant by using the new endpoint:

```
GET /api/v1/participants/npq/{participant_id}/outcomes
```

## 21 September 2022

Providers may need to consider funding and administrative implications of non-UK participants registering for NPQs. Providers can now identify non-UK registrations using three new participant data fields in the API:

1. `teacher_catchment` - this field will indicate whether or not the participant is UK-based:
  * if `true` then the registration relates to a participant who is UK-based
  * if `false` then the registration relates to a participant who is not UK-based
2. `teacher_catchment_iso_country_code` - this field identifies which non-UK country the participant has registered from. The API uses [ISO 3166 alpha-3 codes](https://www.iso.org/iso-3166-country-codes.html), three-letter codes published by the International Organization for Standardization (ISO) to represent countries, dependent territories, and special areas of geographical interest.
3. `teacher_catchment_country` - this field shows the text entered by the participant during their NPQ online registration.

### Example

A teacher from a country outside the UK uses the DfE’s digital service to register for an NPQ. The provider wants to identify the country the participant is registering from, so checks the API and finds:

* `"teacher_catchment": false` - this means the participant is not UK-based
* `"teacher_catchment_iso_country_code": "FRA"` - the provider investigates the result and identifies the participant is based in France
* `"teacher_catchment_country": "France"` - the provider views the text the participant has entered in their online registration

## 14 September 2022

The API will now return a 422 error message to highlight invalid ECF or NPQ `course_identifier` entries.

Invalid entries include:

* spelling errors
* unrecognised values not included in the schema, or a value included in the schema but not associated with the participant

### Example

When updating a participant record, an ECF provider enters an invalid `course_identifier`:

* a provider enters `"course_identifier": "ecf-induction"` when the participant is actually an `ecf-mentor`
* the API will check the `course_identifier` is valid against the `participant_id`
* this will identify whether or not the participant is registered for the given training
* the API will recognise that the `course_identifier` entered by the provider is invalid (as it should be `"course_identifier": "ecf-mentor"`)
* the API will return a 422 error message: `“The property '#/course_identifier' must be an available course to '#/participant_id'”`
* the provider will know to update the `course_identifier` entered

## 24 August 2022

ECF and NPQ lead providers can now trigger clawbacks of declarations which the DfE has paid to them.

To do this, use the void endpoint. This can be done for both API versions (1.0.0 and 2.0.0):

* a provider uses the void endpoint to void a declaration that was in the paid state
* the state of the declaration will then become awaiting_clawback
* on the next statement the DfE will then clawback the value of the declaration, including any associated uplift fee

## 17 August 2022

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

These non-standard schedules start on the first day of the month of the given schedule name. For example, 'ecf-extended-january' starts on 1 January 2023.

## 9 August 2022

Added `targeted_delivery_funding_eligibility` to NPQ applications.

## 2 August 2022

Removed the logic where the API would nullify the `email` field on the ECF and NPQ participant responses where the `status` is withdrawn. Now, where `status` is withdrawn, we will continue to display the participant’s `email`. Generally, the `status` will show withdrawn when a School Induction Tutor has withdrawn or “deleted” a participant in the schools user interface or “portal”. Where `email` was nullified, they will now be visible again.

## 24 June 2022

Added new declaration states `awaiting-clawback` and `clawed-back`.

## 6 June 2022

With this release we've:

* added `cohort` to NPQ applications
* added ability to filter by `cohort` on NPQ applications
* added `ineligible_for_funding_reason` on NPQ applications
* updated `eligible_for_funding` on NPQ applications to take previous accepted applications into consideration

## 11 May 2022

Added `yes_in_first_five_years` and `yes_over_five_years` to `headteacher_status` for NPQ applications.

## 21 April 2022

Added `works_in_school`, `employer_name`, and `employment_role` to `NPQApplicationAttributes` API entities. Definitions available at `/api-reference/reference-v1.html#schema-npqapplication`.

## 12 April 2022

When fetching participant declarations it will now return any declarations made by previous providers. This will allow you to determine what declarations you should be posting next.

## 8 March 2022

In the documentation `/api-reference/reference.html` has been moved to `/api-reference/reference-v1.html`.

## 12 January 2022

`change-schedule` API endpoints now accept a `cohort` attribute in the request body. This defaults to the current cohort if it is not specified.

## 11 January 2022

Added new API endpoint `/api/v1/participants/ecf/{participant_id}/change-schedule`.

## 7 January 2022

Added schedule with identifier `ecf-standard-april`.

## 6 January 2022

Schedule identifier has been renamed from `ecf-september-standard-2021` to `ecf-standard-september`.

Schedule identifier has been renamed from `ecf-january-standard-2021` to `ecf-standard-january`.

## 3 December 2021

Return JSON responses for 404 and 401 errors rather than `text/plain`.

## 4 November 2021

With this release we've:

* added ability to defer an NPQ participant from a given course. `PUT /api/v1/participants/npq/{id}/defer`
* added the new endpoint to defer an NPQ participant from a given course. `PUT /api/v1/participants/npq/{id}/defer`
* added ability to resume an NPQ participant from a given course. `PUT /api/v1/participants/npq/{id}/resume`
* added the new endpoint to resume an NPQ participant from a given course. `PUT /api/v1/participants/npq/{id}/resume`
* added 'updated_at' date to NPQ applications, NPQ participants, participants, and participant declarations (GET endpoints)

## 27 October 2021

Added created_at date to NPQ applications (GET endpoints).

## 25 October 2021

Add `employer` as possible option for NPQ `funding_choice`.

## 19 October 2021

With this release we've:

* added ability to withdraw an NPQ participant from a given course. `PUT /api/v1/participants/npq/{id}/withdraw`
* added the new endpoint to withdraw an NPQ participant from a given course. `PUT /api/v1/participants/npq/{id}/withdraw`

The previous endpoint `PUT /api/v1/participants/npq/{id}/withdraw` is deprecated and will be removed in a later version of the API.

## 5 October 2021

Update withdrawal and deferral reason codes.

Added created_at date to NPQ applications (GET endpoints).

## 29 September 2021

Added `GET /api/v1/participants/npq` endpoint.

## 22 September 2021

Prevent changing schedule if the new schedule makes existing pending declaration invalid.

## 17 September 2021

Add `GET /api/v1/participants/ecf` endpoint.

## 16 September 2021

Share `pupil_premium_uplift` and `sparsity_uplift` values for ECF participants.

## 15 September 2021

Ability to void participant declarations.

## 10 September 2021

Ability to resume participants on a course.

## 9 September 2021

Added new action to retrieve a single participant declaration by ID.

## 8 September 2021

Ability to defer participants on a course.

## 7 September 2021

Standardise date filtering parameters between different API endpoints.

## 19 July 2021

Initial release of the NPQ usage guide.

## 1 July 2021

Initial release of the API reference documentation.
