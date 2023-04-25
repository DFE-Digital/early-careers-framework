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


### NPQ schedules and courses

NPQ courses (for example. npq-leading-teaching) can vary in their length and the number of milestones they comprise. To account for this, and avoid schedules for each and every NPQ course, the DfE have developed schedule types that cover common courses.

For example, if a participant is starting their NPQ in Specialist Leadership in February 2022, the provider needs to make sure the participant’s schedule is npq-leadership-spring and the cohort is 2021.

<table>
  <thead>
    <tr><th>NPQ course</th><th>Available schedules</th></tr>
  </thead>
  <tbody>
    <tr>
      <td>
        NPQSL<br/>
        NPQH<br/>
        NPQEL
      </td>
      <td>
        npq-leadership-autumn<br/>
        npq-leadership-spring
      </td>
    </tr>
    <tr>
      <td>
          NPQLTD<br/>
          NPQLT<br/>
          NPQLBC
      </td>
      <td>
        npq-specialist-autumn<br/>
        npq-specialist-spring
      </td>
    </tr>
  </tbody>
</table>

### Additional Support Offer (ASO) schedule

The DfE has developed schedules for participants taking up the additional support offer.

The provider should make sure the ASO schedule aligns with when a participant starts their ASO. Unlike NPQs, ASO schedules include calendar months.

For example, for a participant starting their ASO in December 2021, the provider should make sure the participant is on the npq-aso-december schedule and the cohort is 2021.

The available ASO schedules are:

* npq-aso-november
* npq-aso-december
* npq-aso-march
* npq-aso-june

### Milestone validation

For NPQ schedules, the DfE does not apply any milestone validation. The API will accept any and all declarations once the first milestone period for the schedule has started.

For example, if a participant is on an npq-leadership-autumn schedule, the API will accept any type of declaration, such as a start, retention-1 or completion, from 1 November 2021.