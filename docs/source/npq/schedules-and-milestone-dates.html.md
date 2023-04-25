---
title: Schedules and milestone dates
weight: 3
---

# Schedules and milestone dates

The DfE makes payment to providers in line with agreed contractual schedules and training criteria. 

Providers are paid a proportionate sum of money relative to the amount of time they support their participants.

NPQ courses can vary in length, and so can each have a different number of milestones. The API will automatically assign schedules to participants depending on when course applications are accepted by providers. 

Providers must [submit declarations](/api-reference/npq/guidance/#submit-view-and-void-declarations) ahead of milestone dates (deadlines) to ensure payments are made for a given milestone. 

Note, we advise providers to keep schedule data independent from any experience logic in their systems. Schedules and cohorts are financial concepts specific to the CPD service and payments. 

## Key concepts

| Concept      | Definition| 
| -------- | --------  |
| Schedule    | The timeframe in which a participant starts a particular NPQ course, which determines milestone dates      |
| Milestone   | Contractual retention periods during which providers must submit relevant declarations evidencing ECF-based training delivery and participant retention     |
| Milestone dates    | The deadline date a valid declaration can be made for a given milestone in order for the DfE to be liable to make a payment the following month. Milestone dates are dependent on the participant’s schedule       |
| Milestone period    | The period of time between the milestone start date and deadline date       |
| Output payment    | The sum of money paid by DfE to providers per valid declaration     |
| Payment date    | The date the DfE will make payment for valid declarations submitted by providers for a given milestone     |
| Milestone validation    | The API's process to validate declarations submitted by providers for participants in standard training schedules       |


## Specialist and leadership schedules

The API will automatically assign schedules to participants on leadership or specialist courses depending on when applications are accepted by providers.

NPQs in specialist areas of teaching will be assigned to one of the following: 

* `npq-specialist-autumn`
* `npq-specialist-spring`

Leadership NPQs will be assigned to one of the following:

* `npq-leadership-autumn`
* `npq-leadership-spring`

Milestone validation is not applied to NPQ schedules. The API will accept any declarations submitted after the first milestone period has started for a given schedule.

For example, if a participant is on an npq-leadership-autumn schedule, the API will accept any type of declaration (including `started`, `retention-{x}` or `completed`) after the schedule start date.

## Early headship coaching offer (EHCO) schedules 

EHCO participant schedules must reflect the month the participant starts their course. 

For example, for participants starting an EHCO in December 2021, providers must make sure they are assigned the `npq-aso-december` schedule.

EHCO schedules include: 

* `npq-ehco-november`
* `npq-ehco-december`
* `npq-ehco-march`
* `npq-ehco-june`

### 2023 cohort 


### 2022 cohort 


### 2021 cohort 


## Additional support offer (ASO) schedules  

ASO participant schedules must reflect the month the participant starts their course. 

For example, for participants starting their ASO in December 2021, providers must make sure they are assigned the `npq-aso-december` schedule.

ASO schedules are only available for the 2021 cohort, and include: 

* `npq-aso-november`
* `npq-aso-december`
* `npq-aso-march`
* `npq-aso-june`

### 2021 cohort
