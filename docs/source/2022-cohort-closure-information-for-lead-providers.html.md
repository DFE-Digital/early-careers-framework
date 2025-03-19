---
title: 2022 cohort closure: information for lead providers
weight: 4
---

# 2022 cohort closure: information for lead providers 

Published: 19 March 2025

## Background 

We’re closing the 2022 cohort at the end of July 2025. This means: 

* lead providers will no longer be able to receive payments for training participants assigned to that cohort
* we'll stop generating output fee statements for the 2022 cohort
* we'll move partially trained early career teachers (ECTs) assigned to the 2022 contract to the 2024 cohort if there’s evidence they require training during the 2025/26 academic year 

### How we’ll handle participants who haven’t completed their training by 31 July 

| Training status   | Post-2022 cohort closure | 
| -------------------- | ---------------------- | 
| Partially trained ECTs | We'll move these ECTs to the 2024 cohort if there’s evidence they require training during the 2025/26 academic year | 
| Partially trained mentors | We will not transfer mentors to the 2024 cohort because they’re not eligible for further training. We’ll mark them as `completed` and update their `mentor_funding_end_date` | 
| ECTs and mentors with no `eligible`, `payable`, `paid`, `awaiting_clawback` or `clawed_back` declarations | We’ll archive these participants. Providers should retire their records. If they’re re-registered in the 2025/26 academic year, they’ll have new IDs | 

## Moving ECTs to the 2024 cohort 

For ECTs where there's evidence they require training during the 2025/26 academic year, we’ll start moving them to the 2024 cohort when registration opens in June. 

We’ll have the following automatic triggers to move partially trained ECTs to the 2024 cohort: 

* if they're registered as transferring into the school after June 2025
* if the participant is still recorded as currently serving induction in the ‘Record inductions as an appropriate body’ service after mid-September 2025 

These triggers will only take place if the induction tutor has set up their school’s 2025/26 programme. 

Once the participant is in the 2024 cohort and the correct partnership is in place, providers will be able to continue getting their details over the API and declare for them in line with the 2024 milestones.  

## Identifying ECTs who we've moved to the 2024 cohort  

To help providers identify these ECTs in the API v3 test environment, there’s a field in the `GET participant` API endpoints called `cohort_changed_after_payments_frozen`. 

For ECTs who’ve moved to the 2024 cohort, the field will have a `TRUE` value in it. 

When calling the `GET participant` endpoint, the ECT’s `cohort` value will be `2024`. 

When calling the `GET participant-declarations` endpoint, the ECT will have historical declarations in their original cohort. 

Providers should use the `cohort_changed_after_payments_frozen` field to identify the ECT. 

We’ll also assign these ECTs to the `ecf-extended-september` schedule. This allows providers to submit any required declarations for the 2025/26 academic year.    

## Updating enrolment records 

Once we’ve moved a participant to the 2024 cohort, the next time a provider retrieves participant details via the API they’ll notice the `cohort` field’s value will be `2024`.  

Providers will need to update their enrolment records so that participants moved to the 2024 cohort are tagged correctly. 

Provider CRMs will need to handle having declarations spanning across multiple cohorts if they keep these records. 

Providers will also need to update the enrolment cohort to the latest one. 

## Raising outstanding declarations 

Where possible, providers should submit any outstanding declarations for participants currently in the 2022 cohort before registration for the 2025/26 academic year opens. 

If the provider is the default for both the 2022 and 2024 cohorts, they can temporarily restore the participant to the 2022 cohort to make a declaration, then move them back to 2024 if needed.  

If a declaration has already been made in 2024, they must:  

1. Void it.
2. Revert to 2022 and make the declaration there.
3. Restore to 2024 and redeclare there. 

Where this is not possible, providers will have to ask us via the Slack channels to move the participants between cohorts.  

<div class="govuk-inset-text">Unlike when we closed the 2021 cohort, mentors who started training in 2022 will not be able to be moved between frozen cohorts. This is because they will be marked as `completed`.</div>

## Voiding declarations 

Providers will no longer be able to void declarations previously paid in the 2022 cohort after 31 July 2025.  

Contract management and assurance will carry out final checks and be in touch before the 2022 cohort is closed. 

ECTs who are still in the 2022 cohort and have not been identified as continuing to train will also no longer be eligible to be declared for after the 31 July 2025. Providers will get a 422-error message asking them to contact us if they think this participant should be moved and declared for. 

## Testing future declaration submissions in the 2024 cohort 

For ECTs moved to the new cohort, providers will be able to continue to declare for them in line with the milestones of the 2024 call-off contracts. These will be agreed between providers and their DfE contract manager. 

## Test data 

We’ve set up dummy data/contracts and milestones in the [test (sandbox) environment](https://sb.manage-training-for-early-career-teachers.education.gov.uk/) to support providers before registration opens.  

Providers will be able to identify participants with the `cohort_changed_after_payments_frozen` field.  

## Provider checklist 

Ahead of the 2022 cohort closing, we recommend providers: 

* check their CRM to make sure they can handle an enrolment in a new cohort with declarations spanning across 2022 and 2024
* familiarise themselves with the `cohort_changed_after_payments_frozen` field in the `GET participant` endpoint response
* check they can see historically submitted declarations made in a previous cohort in the `GET participant-declarations` endpoint when using the cohort filter
* attempt some [future declarations](/api-reference/ecf/guidance/?#test-the-ability-to-submit-declarations-in-sandbox-ahead-of-time) and ensure they’re recorded and handled safely in their CRM
* raise any outstanding declarations for the participants in the 2022 cohort before 31 July 2025 
