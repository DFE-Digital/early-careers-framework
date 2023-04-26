---
title: Schedules and milestone dates
weight: 3
---

# Schedules and milestone dates

The DfE makes payment to providers in line with agreed contractual schedules and training criteria. 

Providers are paid a proportionate sum of money relative to the amount of time they support their participants.

Providers must [submit declarations](/api-reference/ecf/guidance/#submit-view-and-void-declarations) ahead of milestone dates (deadlines) to ensure payments are made for a given milestone. 

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


## Standard training schedules and dates

A default 2 year induction training schedule covers 6 terms (3 in each academic year), and therefore has 6 milestones. 

The payment model is such that for each of the 6 terms a provider is supporting a participant, DfE will pay the corresponding output payment according to valid declarations submitted.

Declarations submitted for participants in standard schedules will be validated (accepted or rejected) against the 6 milestone dates. [View details on milestone validation for standard training schedules](/api-reference/ecf/schedules-and-milestone-dates/#validating-declarations-against-milestones).

<div class="govuk-inset-text">Note, all participants will be registered by default to a standard schedule starting in September. </div>

Providers must [notify DfE if the participant is following any other standard or non-standard training schedule](/api-reference/ecf/guidance/#notify-dfe-a-participant-has-changed-their-training-schedule). Contact ECF contract managers via email for additional support or information. 



### Dates for standard schedule starting in September

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

Participants starting their ECF-based training between 1 January and 31 March 2024, and who are expected to complete their training over 2 academic years, [should have their schedule updated](/api-reference/ecf/guidance/#notify-dfe-a-participant-has-changed-their-training-schedule) by providers to: 

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

Participants starting their ECF-based training between 1 January and 31 March 2023, and who are expected to complete their training over 2 academic years, [should have their schedule updated](/api-reference/ecf/guidance/#notify-dfe-a-participant-has-changed-their-training-schedule) by providers to: 

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

For participants starting their course on or before 1 December 2021, and who are expected to complete their training over 2 academic years, providers [should have their schedule updated](/api-reference/ecf/guidance/#notify-dfe-a-participant-has-changed-their-training-schedule) by providers to: 

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

#### 2023 cohort

Participants starting their ECF-based training between 1 April and 31 July 2024, and who are expected to complete their training over 2 academic years, [should have their schedule updated](/api-reference/ecf/guidance/#notify-dfe-a-participant-has-changed-their-training-schedule) by providers to: 

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

Participants starting their ECF-based training between 1 April and 31 July 2023, and who are expected to complete their training over 2 academic years, [should have their schedule updated](/api-reference/ecf/guidance/#notify-dfe-a-participant-has-changed-their-training-schedule) by providers to: 

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

For participants starting their course on or before 1 February 2022, and who are expected to complete their training over 2 academic years, providers [should have their schedule updated](/api-reference/ecf/guidance/#notify-dfe-a-participant-has-changed-their-training-schedule) by providers to: 

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
* it corresponds to a participant's [updated schedule](/api-reference/ecf/guidance/#notify-dfe-a-participant-has-changed-their-training-schedule), but the participant has previously submitted declarations corresponding to the former schedule (which have not yet been voided).

## Non-standard training schedules and dates

A standard 2 year induction training schedule covers 6 terms (3 in each academic year), and therefore has 6 milestones. However, a participant can choose to follow a non-standard schedule: extended, reduced or replacement.  

The payment model for non-standard schedules follows the same principles; DfE will pay the equivalent of 1 output payment (according to valid declarations submitted) for each of the 6 terms a provider is supporting a participant.

Declarations submitted for participants in non-standard schedules do not need API milestone validation. 

**Providers should note:**

* All participants will be registered by default to a standard schedule starting in September
* Providers must [notify DfE if the participant is following any other standard or non-standard training schedule](/api-reference/ecf/guidance/#notify-dfe-a-participant-has-changed-their-training-schedule)
* Providers will need to evidence any declarations and why a participant is following a non-standard induction 

### Extended schedules

While the API will accept any declarations submitted after the first milestone start date (1 September, 1 January, 1 April each year), providers must submit declarations according to the terms outlined in the ECF contract payment guidance. 

Contact ECF contract managers via email for more information on exact dates.

Participants who expect to complete their ECF-based training in more than 2 years, should have their [schedule updated](/api-reference/ecf/guidance/#notify-dfe-a-participant-has-changed-their-training-schedule) to one for the following: 

```
 "schedule_identifier": "ecf-extended-september"
```

```
 "schedule_identifier": "ecf-extended-january"
```

```
 "schedule_identifier": "ecf-extended-april"
```

### Reduced schedules

While the API will accept any declarations submitted after the first milestone start date (1 September, 1 January, 1 April each year), providers must submit declarations according to the terms outlined in the ECF contract payment guidance. 

Contact ECF contract managers via email for more information on exact dates.

Participants who expect to complete their ECF-based training in less than 2 years, should have their [schedule updated](/api-reference/ecf/guidance/#notify-dfe-a-participant-has-changed-their-training-schedule) to one for the following: 

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

* Replacement schedules should only be used where a new mentor takes the place of a previous mentor (in supporting an ECT’s training), but where the new mentor is not also mentoring any other ECTs.
* Replacement schedules should not be used if a mentor is already mentoring an ECT and takes on an additional role replacing a mentor for a second ECT. A mentor’s first ECT should take precedence in determining their schedule.

Mentors that are not already training ECTs and are replacing a mentor must be should have their [schedule updated](/api-reference/ecf/guidance/#notify-dfe-a-participant-has-changed-their-training-schedule) to one for the following: 

```
 "schedule_identifier": "ecf-replacement-september"
```

```
 "schedule_identifier": "ecf-replacement-january"
```

```
 "schedule_identifier": "ecf-replacement-april"
```
