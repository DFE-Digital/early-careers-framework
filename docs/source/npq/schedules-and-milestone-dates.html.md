---
title: Schedules and milestone dates
weight: 3
---

# Schedules and milestone dates

### NPQ schedules and dates

NPQ participants start their courses at different times throughout the school year. The DfE has developed schedules to account for these different start dates, which are sometimes called ‘cohorts’.

Currently, the DfE expects NPQ participants to start an NPQ course in ‘autumn’ or ‘spring’.

Participants that start their course in November/December 2021 should be on autumn schedules, while participants that start their course in January/February 2022 are on spring schedules.

The DfE automatically assigns an NPQ participant to a schedule when the participant registers. The schedule assigned depends on the date when the participant registers, with the following logic:
* assigned participants who registered and were accepted before  25 December 2021 to an autumn schedule
* assigned participants who registered and were accepted after 25 December 2021 to a spring schedule

### NPQ cohort attribute

The NPQ participant [change schedule attributes](/api-reference/reference-v1.html#schema-npqparticipantchangescheduleattributes) includes the attribute ‘cohort’.

The DfE uses the attribute cohort to record the academic year in which a teacher creates an application for an NPQ. Currently the only available cohort is 2021, representing any NPQ application made in the academic year 2021/22. The DfE will expand this in future years.

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