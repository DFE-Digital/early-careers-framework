---
title: Schedules and milestone dates
weight: 3
---

# Schedules and milestone dates

This section explains the contractual retention periods in which lead providers must submit declarations to show training delivery and participant retention. 

DfE pays providers based on agreed contractual schedules and training delivery criteria. Payments are proportional to the time providers support their participants. 

<div class="govuk-warning-text"> 
<span class="govuk-warning-text__icon" aria-hidden="true">!</span> 
<strong class="govuk-warning-text__text"> 
<span class="govuk-warning-text__assistive">Warning</span> 
Providers must submit declarations before each milestone deadline to receive the related payment. 
</strong> 
</div> 

Access to training materials should not be tied to a participant’s cohort or schedule.  

## Key concepts

| Concept      | Definition| 
| -------- | --------  |
| Schedule    | The expected timeframe in which a participant will complete their ECF-based training, which determine the defined milestone dates      |
| Standard schedule  | The default training schedule for participants completing a standard 2 year induction, starting in September, January or April  |
| Extended schedule   | A non-standard training schedule for participants who expect to complete the induction over a period greater than 2 years. Examples include part-time ECTs, or ECTs whose induction period is extended by their appropriate body  |
| Reduced schedule   | A non-standard training schedule for participants who expect to complete the induction over a period less than 2 years.  Examples include those with previous experience  |
| Replacement schedule  | A non-standard training schedule for mentors that are replacing a previous mentor for an ECT that is part way through their training  |
| Milestone   | Contractual retention periods during which providers must submit relevant declarations evidencing ECF-based training delivery and participant retention     |
| Milestone dates    | The deadline date a valid declaration can be made for a given milestone in order for the DfE to be liable to make a payment the following month. Milestone dates are dependent on the participant’s schedule       |
| Milestone period    | The period of time between the milestone start date and deadline date       |
| Output payment    | The sum of money paid by DfE to providers per valid declaration     |
| Payment date    | The date the DfE will make payment for valid declarations submitted by providers for a given milestone     |
| Milestone validation    | The API's process to validate declarations submitted by providers for participants in standard training schedules        |


## Standard schedules and dates

A default 2 year induction training schedule covers 6 terms (3 in each academic year), and therefore has 6 milestones. 

The payment model is such that for each of the 6 terms a provider is supporting a participant, DfE will pay the corresponding output payment according to valid declarations submitted.

Declarations submitted for participants in standard schedules will be validated (accepted or rejected) against the 6 milestone dates. [View details on milestone validation for standard training schedules](/api-reference/ecf/schedules-and-milestone-dates/#validating-declarations-against-milestones).

<div class="govuk-inset-text">Note, all participants will be registered by default to a standard schedule starting in September. </div>

Providers must [notify DfE if the participant is following any other standard or non-standard training schedule](/api-reference/ecf/guidance.html#notify-dfe-of-a-participant-39-s-training-schedule). Contact ECF contract managers via email for additional support or information. 


### Dates for standard schedule starting in September

#### 2024 cohort

Participants starting their ECF-based training on or before 31 December 2024, and who are expected to complete their training over 2 academic years, should remain on the default schedule:

```
 "schedule_identifier": "ecf-standard-september"
```

| Milestone      | Start date     | Milestone date      | Declaration type    | Payment date      | 
| -------- | --------  | -------- | --------  | -------- | 
| Participant Start      | 1 Jun 2024     | 31 Dec 2024     | `started`    | 30 Nov 2024      | 
| Retention Point 1      | 1 Jan 2025     | 31 Mar 2025      | `retained-1`    | 30 Apr 2025     | 
| Retention Point 2      | 1 Apr 2025     | 31 Jul 2025      | `retained-2`    | 31 Aug 2025     | 
| Retention Point 3      | 1 Aug 2025     | 31 Dec 2025      | `retained-3`    | 31 Jan 2026      | 
| Retention Point 4      | 1 Jan 2026     | 31 Mar 2026      | `retained-4`    | 30 Apr 2026     | 
| Participant Completion      | 1 Apr 2026     | 31 Jul 2026      | `completed`    | 31 Aug 2026      | 


#### 2023 cohort

Participants starting their ECF-based training on or before 31 December 2023, and who are expected to complete their training over 2 academic years, should remain on the default schedule:

```
 "schedule_identifier": "ecf-standard-september"
```

| Milestone      | Start date     | Milestone date      | Declaration type    | Payment date      | 
| -------- | --------  | -------- | --------  | -------- | 
| Participant Start      | 1 Jun 2023     | 31 Dec 2023     | `started`    | 30 Nov 2023      | 
| Retention Point 1      | 1 Jan 2024     | 31 Mar 2024      | `retained-1`    | 30 Apr 2024     | 
| Retention Point 2      | 1 Apr 2024     | 31 Jul 2024      | `retained-2`    | 31 Aug 2024     | 
| Retention Point 3      | 1 Aug 2024     | 31 Dec 2024      | `retained-3`    | 31 Jan 2025      | 
| Retention Point 4      | 1 Jan 2025     | 31 Mar 2025      | `retained-4`    | 30 Apr 2025     | 
| Participant Completion      | 1 Apr 2025     | 31 Jul 2025      | `completed`    | 31 Aug 2025      | 


#### 2022 cohort

Participants starting their ECF-based training on or before 31 December 2022, and who are expected to complete their training over 2 academic years, should remain on the default schedule:

```
 "schedule_identifier": "ecf-standard-september"
```

| Milestone      | Start date     | Milestone date      | Declaration type    | Payment date      | 
| -------- | --------  | -------- | --------  | -------- | 
| Participant Start      | 1 Jun 2022     | 31 Dec 2022     | `started`    | 30 Nov 2022      | 
| Retention Point 1      | 1 Jan 2023     | 31 Mar 2023      | `retained-1`    | 30 Apr 2023     | 
| Retention Point 2      | 1 Apr 2023     | 31 Jul 2023      | `retained-2`    | 31 Aug 2023     | 
| Retention Point 3      | 1 Aug 2023     | 31 Dec 2023      | `retained-3`    | 31 Jan 2024      | 
| Retention Point 4      | 1 Jan 2024     | 31 Mar 2024      | `retained-4`    | 30 Apr 2024     | 
| Participant Completion      | 1 Apr 2024     | 31 Jul 2024      | `completed`    | 31 Aug 2024      | 

#### 2021 cohort

Participants starting their ECF-based training on or before 30 November 2021, and who are expected to complete their training over 2 academic years, should remain on the default schedule:

```
 "schedule_identifier": "ecf-standard-september"
```

| Milestone      | Start date     | Milestone date      | Declaration type    | Payment date      | 
| -------- | --------  | -------- | --------  | -------- | 
| Participant Start      | 1 Sep 2021    | 30 Nov 2021     | `started`    | 30 Nov 2021      | 
| Retention Point 1      | 1 Sep 2021     | 31 Jan 2022      | `retained-1`    | 28 Feb 2022      | 
| Retention Point 2      | 1 Feb 2022     | 30 Apr 2022      | `retained-2`    | 31 May 2022      | 
| Retention Point 3      | 1 May 2022     | 30 Sep 2022      | `retained-3`    | 31 Oct 2022      | 
| Retention Point 4      | 1 Oct 2022     | 31 Jan 2023      | `retained-4`    | 28 Feb 2023      | 
| Participant Completion      | 1 Feb 2023     | 30 Apr 2023      | `completed`    | 31 May 2023      | 


### Dates for standard schedule starting in January

#### 2024 cohort

Participants starting their ECF-based training between 1 January and 31 March 2025, and who are expected to complete their training over 2 academic years, [should have their schedule updated](/api-reference/ecf/guidance.html#notify-dfe-of-a-participant-39-s-training-schedule) by providers to: 

```
 "schedule_identifier": "ecf-standard-january"
```

| Milestone      | Start date     | Milestone date      | Declaration type    | Payment date      | 
| -------- | --------  | -------- | --------  | -------- | 
| Participant Start      | 1 Jan 2025     | 31 Mar 2025      | `started`    | 30 Apr 2025      | 
| Retention Point 1      | 1 Apr 2025    | 31 Jul 2025      | `retained-1`    | 31 Aug 2025      | 
| Retention Point 2      | 1 Aug 2025     | 31 Dec 2025      | `retained-2`    | 31 Jan 2026      | 
| Retention Point 3      | 1 Jan 2026     | 31 Mar 2026      | `retained-3`    | 30 Apr 2026      | 
| Retention Point 4      | 1 Apr 2026     | 31 Jul 2026      | `retained-4`    | 31 Aug 2026      | 
| Participant Completion      | 1 Aug 2026     | 31 Dec 2026      | `completed`    | 31 Jan 2027      | 

#### 2023 cohort

Participants starting their ECF-based training between 1 January and 31 March 2024, and who are expected to complete their training over 2 academic years, [should have their schedule updated](/api-reference/ecf/guidance.html#notify-dfe-of-a-participant-39-s-training-schedule) by providers to: 

```
 "schedule_identifier": "ecf-standard-january"
```

| Milestone      | Start date     | Milestone date      | Declaration type    | Payment date      | 
| -------- | --------  | -------- | --------  | -------- | 
| Participant Start      | 1 Jan 2024     | 31 Mar 2024      | `started`    | 30 Apr 2024      | 
| Retention Point 1      | 1 Apr 2024    | 31 Jul 2024      | `retained-1`    | 31 Aug 2024      | 
| Retention Point 2      | 1 Aug 2024     | 31 Dec 2024      | `retained-2`    | 31 Jan 2025      | 
| Retention Point 3      | 1 Jan 2025     | 31 Mar 2025      | `retained-3`    | 30 Apr 2025      | 
| Retention Point 4      | 1 Apr 2025     | 31 Jul 2025      | `retained-4`    | 31 Aug 2025      | 
| Participant Completion      | 1 Aug 2025     | 31 Dec 2025      | `completed`    | 31 Jan 2026      | 

#### 2022 cohort

Participants starting their ECF-based training between 1 January and 31 March 2023, and who are expected to complete their training over 2 academic years, [should have their schedule updated](/api-reference/ecf/guidance.html#notify-dfe-of-a-participant-39-s-training-schedule) by providers to: 

```
 "schedule_identifier": "ecf-standard-january"
```

| Milestone      | Start date     | Milestone date      | Declaration type    | Payment date      | 
| -------- | --------  | -------- | --------  | -------- | 
| Participant Start      | 1 Jan 2023     | 31 Mar 2023      | `started`    | 30 Apr 2023      | 
| Retention Point 1      | 1 Apr 2023    | 31 Jul 2023      | `retained-1`    | 31 Aug 2023      | 
| Retention Point 2      | 1 Aug 2023     | 31 Dec 2023      | `retained-2`    | 31 Jan 2024      | 
| Retention Point 3      | 1 Jan 2024     | 31 Mar 2024      | `retained-3`    | 30 Apr 2024      | 
| Retention Point 4      | 1 Apr 2024     | 31 Jul 2024      | `retained-4`    | 31 Aug 2024      | 
| Participant Completion      | 1 Aug 2024     | 31 Dec 2024      | `completed`    | 31 Jan 2025      | 

#### 2021 cohort

For participants starting their course on or before 1 December 2021, and who are expected to complete their training over 2 academic years, providers [should have their schedule updated](/api-reference/ecf/guidance.html#notify-dfe-of-a-participant-39-s-training-schedule) by providers to: 

```
 "schedule_identifier": "ecf-standard-january"
```

| Milestone      | Start date     | Milestone date      | Declaration type    | Payment date      | 
| -------- | --------  | -------- | --------  | -------- | 
| Participant Start      | 1 Dec 2021     | 31 Jan 2022      | `started`    | 28 Feb 2022      | 
| Retention Point 1      | 1 Feb 2022     | 30 Apr 2022      | `retained-1`    | 31 May 2022      | 
| Retention Point 2      | 1 May 2022     | 30 Sep 2022      | `retained-2`    | 31 Oct 2022      | 
| Retention Point 3      | 1 Oct 2022     | 31 Jan 2023      | `retained-3`    | 28 Feb 2023      | 
| Retention Point 4      | 1 Feb 2023     | 30 Apr 2023      | `retained-4`    | 31 May 2023      | 
| Participant Completion      | 1 May 2023     | 31 Oct 2023      | `completed`    | 30 Nov 2023      | 


### Dates for standard schedule starting in April

#### 2024 cohort

Participants starting their ECF-based training between 1 April and 31 July 2025, and who are expected to complete their training over 2 academic years, [should have their schedule updated](/api-reference/ecf/guidance.html#notify-dfe-of-a-participant-39-s-training-schedule) by providers to: 

```
 "schedule_identifier": "ecf-standard-april"
```

| Milestone      | Start date     | Milestone date      | Declaration type    | Payment date      | 
| -------- | --------  | -------- | --------  | -------- | 
| Participant Start      | 1 Apr 2025     | 31 Jul 2025      | `started`    | 31 Aug 2025      | 
| Retention Point 1      | 1 Aug 2025     | 31 Dec 2025     | `retained-1`    | 31 Jan 2026      | 
| Retention Point 2      | 1 Jan 2026     | 31 Mar 2026      | `retained-2`    | 30 Apr 2026     | 
| Retention Point 3      | 1 Apr 2026    | 31 Jul 2026      | `retained-3`    | 31 Aug 2026      | 
| Retention Point 4      | 1 Aug 2026     | 31 Dec 2026      | `retained-4`    | 31 Jan 2027      | 
| Participant Completion      | 1 Jan 2027     | 31 Mar 2027      | `completed`    | 30 Apr 2027      | 


#### 2023 cohort

Participants starting their ECF-based training between 1 April and 31 July 2024, and who are expected to complete their training over 2 academic years, [should have their schedule updated](/api-reference/ecf/guidance.html#notify-dfe-of-a-participant-39-s-training-schedule) by providers to: 

```
 "schedule_identifier": "ecf-standard-april"
```

| Milestone      | Start date     | Milestone date      | Declaration type    | Payment date      | 
| -------- | --------  | -------- | --------  | -------- | 
| Participant Start      | 1 Apr 2024     | 31 Jul 2024      | `started`    | 31 Aug 2024      | 
| Retention Point 1      | 1 Aug 2024     | 31 Dec 2024     | `retained-1`    | 31 Jan 2025      | 
| Retention Point 2      | 1 Jan 2025     | 31 Mar 2025      | `retained-2`    | 30 Apr 2025     | 
| Retention Point 3      | 1 Apr 2025    | 31 Jul 2025      | `retained-3`    | 31 Aug 2025      | 
| Retention Point 4      | 1 Aug 2025     | 31 Dec 2025      | `retained-4`    | 31 Jan 2026      | 
| Participant Completion      | 1 Jan 2026     | 31 Mar 2026      | `completed`    | 30 Apr 2026      | 

#### 2022 cohort

Participants starting their ECF-based training between 1 April and 31 July 2023, and who are expected to complete their training over 2 academic years, [should have their schedule updated](/api-reference/ecf/guidance.html#notify-dfe-of-a-participant-39-s-training-schedule) by providers to: 

```
 "schedule_identifier": "ecf-standard-april"
```

| Milestone      | Start date     | Milestone date      | Declaration type    | Payment date      | 
| -------- | --------  | -------- | --------  | -------- | 
| Participant Start      | 1 Apr 2023     | 31 Jul 2023      | `started`    | 31 Aug 2023      | 
| Retention Point 1      | 1 Aug 2023     | 31 Dec 2023     | `retained-1`    | 31 Jan 2024      | 
| Retention Point 2      | 1 Jan 2024     | 31 Mar 2024      | `retained-2`    | 30 Apr 2024     | 
| Retention Point 3      | 1 Apr 2024    | 31 Jul 2024      | `retained-3`    | 31 Aug 2024      | 
| Retention Point 4      | 1 Aug 2024     | 31 Dec 2024      | `retained-4`    | 31 Jan 2025      | 
| Participant Completion      | 1 Jan 2025     | 31 Mar 2025      | `completed`    | 30 Apr 2025      | 

#### 2021 cohort

For participants starting their course on or before 1 February 2022, and who are expected to complete their training over 2 academic years, providers [should have their schedule updated](/api-reference/ecf/guidance.html#notify-dfe-of-a-participant-39-s-training-schedule) by providers to: 

```
 "schedule_identifier": "ecf-standard-april"
```

| Milestone      | Start date     | Milestone date      | Declaration type    | Payment date      | 
| -------- | --------  | -------- | --------  | -------- | 
| Participant Start      | 1 Feb 2022     | 31 May 2022      | `started`    | 31 May 2022      | 
| Retention Point 1      | 1 May 2022     | 30 Sep 2022      | `retained-1`    | 31 Oct 2022      | 
| Retention Point 2      | 1 Oct 2022     | 31 Jan 2023      | `retained-2`    | 28 Feb 2023     | 
| Retention Point 3      | 1 Feb 2023    | 30 Apr 2023      | `retained-3`    | 31 May 2023      | 
| Retention Point 4      | 1 May 2023     | 31 Oct 2023      | `retained-4`    | 30 Nov 2023      | 
| Participant Completion      | 1 Nov 2023     | 31 Jan 2024      | `completed`    | 28 Feb 2024      | 


### Validating declarations against milestones

Declarations submitted for participants on standard schedules are subject to milestone validation. 

<div class="govuk-inset-text">Note, milestone validation does not apply to any non-standard schedules.</div>

The API will perform milestone validation to reject a declaration if:

* it is not submitted for the correct milestone. For example, the API will reject a `retained-1` declaration if it is submitted during the `started` milestone period
* it is submitted before or after the milestone date. For example, an `ecf-standard-september` schedule allows `started` declarations between 19 November to 30 November. A declaration submitted outside of these dates will be rejected, unless its `declaration_date` is backdated accordingly
* it corresponds to a participant's [updated schedule](/api-reference/ecf/guidance.html#notify-dfe-of-a-participant-39-s-training-schedule), but the participant has previously submitted declarations corresponding to the former schedule (which have not yet been voided).

## Non-standard schedules and dates

A standard 2 year induction training schedule covers 6 terms (3 in each academic year), and therefore has 6 milestones. However, a participant can choose to follow a non-standard schedule: extended, reduced or replacement.  

The payment model for non-standard schedules follows the same principles; DfE will pay the equivalent of 1 output payment (according to valid declarations submitted) for each of the 6 terms a provider is supporting a participant.

Declarations submitted for participants in non-standard schedules do not need API milestone validation. 

**Providers should note:**

* all participants will be registered by default to a standard schedule starting in September
* providers must [notify DfE if the participant is following any other standard or non-standard training schedule](/api-reference/ecf/guidance.html#notify-dfe-of-a-participant-39-s-training-schedule)
* providers will need to evidence any declarations and why a participant is following a non-standard induction 

### Extended schedules

While the API will accept any declarations submitted after the first milestone start date (1 September, 1 January, 1 April each year), providers must submit declarations according to the terms outlined in the ECF contract payment guidance. 

Contact ECF contract managers via email for more information on exact dates.

Participants who expect to complete their ECF-based training in more than 2 years, should have their [schedule updated](/api-reference/ecf/guidance.html#notify-dfe-of-a-participant-39-s-training-schedule) to one for the following: 

```
 "schedule_identifier": "ecf-extended-september"
```

```
 "schedule_identifier": "ecf-extended-january"
```

```
 "schedule_identifier": "ecf-extended-april"
```
Providers may submit extended declarations for ECTs on an extended schedule, providing they meet certain criteria.

Qualifying ECTs will have had their induction extended as a result of having not yet met the Teachers’ standards, and need additional support to meet the standards. These ECTs must be placed onto one of the available [‘extended schedules’](/api-reference/ecf/schedules-and-milestone-dates.html#extended-schedules) for ECF. 

Providers may submit an extended declaration (subject to meeting the engagement criteria) for each extended term until the ECT has completed their induction, up to a maximum of three extensions. On completing induction, the provider should submit a completion declaration for the final term.

Providers may submit extended declarations using the following values in the `declaration_type` field on the [participant declaration request body](/api-reference/reference-v3.html#schema-participantdeclarationrequest):

* extended-1
* extended-2
* extended-3

### Reduced schedules

Reduced schedules apply to participants that expect to complete their ECF-based training in less than 2 years.

Providers should note:

* providers may identify ECTs that have already completed their induction, and so need to be placed on a reduced schedule, via the API. We include details of the date an ECT completed their induction in the v3 [EcfParticipantAttributes](/api-reference/reference-v3.html#schema-ecfparticipantattributes)
* while the API will accept any declarations submitted after the first milestone start date (1 September, 1 January, 1 April each year), providers must submit declarations according to the terms outlined in the ECF contract payment guidance

Contact ECF contract managers via email for more information on exact dates.

Participants who expect to complete their ECF-based training in less than 2 years, should have their [schedule updated](/api-reference/ecf/guidance.html#notify-dfe-of-a-participant-39-s-training-schedule) to one for the following: 

```
 "schedule_identifier": "ecf-reduced-september"
```

```
 "schedule_identifier": "ecf-reduced-january"
```

```
 "schedule_identifier": "ecf-reduced-april"
```

### Replacement schedules 

While the API will accept any declarations submitted after the first milestone start date (1 September, 1 January, 1 April each year), providers must submit declarations according to the terms outlined in the ECF contract payment guidance. 

Contact ECF contract managers via email for more information on exact dates.

#### Providers should note:

* replacement schedules should only be used where a new mentor takes the place of a previous mentor (in supporting an ECT’s training), but where the new mentor is not also mentoring any other ECTs
* replacement schedules should not be used if a mentor is already mentoring an ECT and takes on an additional role replacing a mentor for a second ECT. A mentor’s first ECT should take precedence in determining their schedule

Mentors that are not already training ECTs and are replacing a mentor must be should have their [schedule updated](/api-reference/ecf/guidance.html#notify-dfe-of-a-participant-39-s-training-schedule) to one for the following: 

```
 "schedule_identifier": "ecf-replacement-september"
```

```
 "schedule_identifier": "ecf-replacement-january"
```

```
 "schedule_identifier": "ecf-replacement-april"
```
