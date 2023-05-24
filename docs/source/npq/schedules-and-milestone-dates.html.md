---
title: Schedules and milestone dates
weight: 3
---

# Schedules and milestone dates

The DfE makes payment to providers in line with agreed contractual schedules and training criteria. 

NPQ courses can vary in length, and so can each have a different number of milestones.

The API will automatically assign schedules to participants depending on when course applications are accepted by providers. 

<div class="govuk-inset-text"> Providers should submit declarations in line with terms set out in their contracts. However the API does not apply milestone validation to those on NPQ schedules. The API will accept any declarations submitted after the first milestone period has started for a given schedule.</div>

For example, if a participant is on an npq-leadership-autumn schedule, the API will accept any type of declaration (including `started`, `retention-{x}` or `completed`) after the schedule start date.

**Note**, we advise providers to keep schedule data independent from any experience logic in their systems. Schedules and cohorts are financial concepts specific to the CPD service and payments.

## Key concepts

| Concept      | Definition| 
| -------- | --------  |
| Schedule    | The timeframe in which a participant starts a particular NPQ course, which determines milestone dates      |
| Milestone   | Contractual retention periods during which providers must submit relevant declarations evidencing training delivery and participant retention     |
| Milestone dates    | The deadline date a valid declaration can be made for a given milestone in order for the DfE to be liable to make a payment the following month. Milestone dates are dependent on the participant’s schedule       |
| Milestone period    | The period of time between the milestone start date and deadline date       |
| Output payment    | The sum of money paid by DfE to providers per valid declaration     |
| Payment date    | The date the DfE will make payment for valid declarations submitted by providers for a given milestone     |
| Milestone validation    | The API's process to validate declarations submitted by providers for participants in standard training schedules       |

## Specialist NPQ schedules

The API will automatically assign schedules to participants on specialist NPQ courses depending on when applications are accepted by providers. 

NPQs in specialist areas of teaching will be assigned to one of the following: 

* `npq-specialist-autumn`
* `npq-specialist-spring`

### Dates for schedules starting in autumn 

Participants starting their specialist NPQ course before 31 December should be assigned with the schedule: 

```
 "schedule_identifier": "npq-specialist-autumn"
```
#### 2023 cohort

The API will accept declarations submitted from **1 October 2023**.

[View upcoming financial statement payment dates.](/api-reference/npq/guidance/#view-financial-statement-payment-dates)

#### 2022 cohort

The API will accept declarations submitted from **1 October 2022**.

[View upcoming financial statement payment dates.](/api-reference/npq/guidance/#view-financial-statement-payment-dates)

#### 2021 cohort

The API will accept declarations submitted from **1 November 2021**.

[View upcoming financial statement payment dates.](/api-reference/npq/guidance/#view-financial-statement-payment-dates)

### Dates for schedules starting in spring 

Participants starting their specialist NPQ course after 1 January should be assigned with the schedule: 

```
 "schedule_identifier": "npq-specialist-spring"
```

#### 2023 cohort

The API will accept declarations submitted from **1 January 2024**.

[View upcoming financial statement payment dates.](/api-reference/npq/guidance/#view-financial-statement-payment-dates)

#### 2022 cohort

The API will accept declarations submitted from **1 January 2023**.

[View upcoming financial statement payment dates.](/api-reference/npq/guidance/#view-financial-statement-payment-dates)

#### 2021 cohort

The API will accept declarations submitted from **1 January 2022**.

[View upcoming financial statement payment dates.](/api-reference/npq/guidance/#view-financial-statement-payment-dates)

## Leadership NPQ schedules

The API will automatically assign schedules to participants on leadership NPQ courses depending on when applications are accepted by providers.

Leadership NPQs will be assigned to one of the following:

* `npq-leadership-autumn`
* `npq-leadership-spring`

### Dates for schedules starting in autumn 

Participants starting their specialist NPQ course before 31 December should be assigned with the schedule: 

```
 "schedule_identifier": "npq-leadership-autumn"
```

#### 2023 cohort

The API will accept declarations submitted from **1 October 2023**.

[View upcoming financial statement payment dates.](/api-reference/npq/guidance/#view-financial-statement-payment-dates)

#### 2022 cohort

The API will accept declarations submitted from **1 October 2022**.

[View upcoming financial statement payment dates.](/api-reference/npq/guidance/#view-financial-statement-payment-dates)

#### 2021 cohort

The API will accept declarations submitted from **1 November 2021**.

[View upcoming financial statement payment dates.](/api-reference/npq/guidance/#view-financial-statement-payment-dates)

### Dates for schedules starting in spring 

Participants starting their specialist NPQ course after 1 January should be assigned with the schedule: 

```
 "schedule_identifier": "npq-leadership-spring"
```

#### 2023 cohort

The API will accept declarations submitted from **1 January 2024**.

[View upcoming financial statement payment dates.](/api-reference/npq/guidance/#view-financial-statement-payment-dates)

#### 2022 cohort

The API will accept declarations submitted from **1 January 2023**.

[View upcoming financial statement payment dates.](/api-reference/npq/guidance/#view-financial-statement-payment-dates)

#### 2021 cohort

The API will accept declarations submitted from **1 January 2022**.

[View upcoming financial statement payment dates.](/api-reference/npq/guidance/#view-financial-statement-payment-dates)

## Early headship coaching offer (EHCO) schedules 

EHCO participant schedules must reflect the month the participant starts their course. 

For example, for participants starting an EHCO in December 2021, providers must make sure they are assigned the `npq-ehco-december` schedule.

EHCO schedules include: 

* `npq-ehco-november`
* `npq-ehco-december`
* `npq-ehco-march`
* `npq-ehco-june`

## Additional support offer (ASO) schedules  

ASO participant schedules must reflect the month the participant starts their course. 

For example, for participants starting their ASO in December 2021, providers must make sure they are assigned the `npq-aso-december` schedule.

ASO schedules are only available for the 2021 cohort, and include: 

* `npq-aso-november`
* `npq-aso-december`
* `npq-aso-march`
* `npq-aso-june`