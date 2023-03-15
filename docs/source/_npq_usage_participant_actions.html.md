## Notifying that an NPQ participant has withdrawn from their course

This operation allows the provider to tell the DfE that a participant has withdrawn from their NPQ course.

A participant that withdraws in a given milestone period after the submission of a retained event for the same period, will be paid for that period.

A participant that withdraws before the started milestone cut-off date will not be paid for by the department.

## Provider withdraws a participant

Submit the withdrawal notification to the following endpoint

```
PUT /api/v1/participants/npq/{id}/withdraw
```

This will return an [NPQ participant record](/api-reference/reference.html#schema-npqparticipantresponse) with the updates to the record included.

See [withdraw NPQ participant](/api-reference/reference.html#api-v1-participants-npq-id-withdraw-put) endpoint.

## Notifying that an NPQ participant is taking a break from their course

This operation allows the provider to tell the DfE that a participant has deferred from their NPQ course.

A participant is deemed to have deferred from an NPQ course if he or she will be resuming it at a later date.

### Provider defers a participant

Submit the deferral notification to the following endpoint

```
PUT /api/v1/participants/npq/{id}/defer
```

This will return an [NPQ participant record](/api-reference/reference-v1#schema-npqparticipantresponse) with the updates to the record included.

See [defer an NPQ participant](/api-reference/reference.html#api-v1-participants-npq-id-defer-put) endpoint.

## Notifying that an NPQ participant is resuming their course

This functionality allows the provider to inform the DfE that a participant has resumed an NPQ course.

### Provider resumes an NPQ participant

Submit the resumed notification to the following endpoint

```
PUT /api/v1/participants/npq/{id}/resume
```

This will return an [NPQ participant record](/api-reference/reference-v1#schema-npqparticipantresponse) with the updates to the record included.

See [resume NPQ participant](/api-reference/reference-v1.html#api-v1-participants-id-resume-put) endpoint.

## Tell the DfE that a participant is changing training schedule on their NPQ course

Submit a change of schedule notification to the following endpoint

```
PUT /api/v1/participants/npq/{id}/change-schedule
```

This will return an [NPQ participant response](/api-reference/reference-v1.html#schema-npqparticipant) with the updates to the record included.

Read change schedule of [NPQ participant endpoint](/api-reference/reference-v1.html#api-v1-participants-npq-id-change-schedule-put).

The provider needs to show the DfE evidence of any declarations they submit and why a participant is following a particular schedule.

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
    <tr>
      <th>NPQ Course</th>
      <th>Available schedules</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>NPQSL<br />NPQH<br />NPQEL</td>
      <td>npq-leadership-autumn<br />npq-leadership-spring</td>
    </tr>
    <tr>
      <td>NPQLTD<br />NPQLT<br />NPQLBC</td>
      <td>npq-specialist-autumn<br />npq-specialist-spring</td>
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

## Declaring that an NPQ participant has started their course

This scenario begins after it has been confirmed that an NPQ participant is ready to begin their induction training.

### Provider confirms an NPQ participant has started

onfirm an NPQ participant has started their induction training before Milestone 1.

```
POST /api/v1/participant-declarations
```

With a [request body containing an NPQ participant declaration](/api-reference/reference-v1#schema-npqparticipantstarteddeclaration).

This returns [participant declaration](/api-reference/reference-v1#schema-singleparticipantdeclarationresponse).

This endpoint is idempotent - submitting exact copy of a request will return the same response body as submitting it the first time.

See [confirm NPQ participant declarations](/api-reference/reference-v1#api-v1-participant-declarations-post) endpoint.

### Provider records the NPQ participant declaration ID

Store the returned NPQ participant declaration ID for future management tasks.

## Declaring that an NPQ participant has reached a retained milestone

This scenario begins after it has been confirmed that an NPQ participant has completed enough of their course to meet a milestone.

### Provider confirms an NPQ participant has been retained

Confirm an NPQ participant has been retained by the appropriate number of months for this retained event on their NPQ course.

An explicit `retained-x` declaration is required to trigger output payments. You should declare this when a participant has reached a particular milestone in line with contractual reporting requirements.

```
POST /api/v1/participant-declarations
```

With a [request body containing an NPQ participant retained declaration](/api-reference/reference-v1#schema-npqparticipantretaineddeclaration).

This returns [participant declaration](/api-reference/reference-v1#schema-singleparticipantdeclarationresponse).

See [confirm NPQ participant declarations](/api-reference/reference-v1#api-v1-participant-declarations-post) endpoint.

### Provider records the NPQ participant declaration ID 

Store the returned NPQ participant declaration ID for future management tasks.

## Declaring that an NPQ participant has completed their course

This scenario begins after it has been confirmed that an NPQ participant has completed their course.

Providers should declare this when a participant has reached their final milestone and completed their NPQ course with a pass or fail outcome.

An explicit `completed` declaration is required to trigger output payments.

### Provider confirms an NPQ participant has completed their course

Confirm a participant has completed their NPQ course.

```
POST /api/v1/participant-declarations
```

The request body must contain all attributes described in the [NPQ participant completed declaration](/api-reference/reference-v1.html#schema-npqparticipantdeclarationcompletedattributesrequest), including a value in the `has_passed` attribute.

This returns [participant declaration](/api-reference/reference-v1#schema-singleparticipantdeclarationresponse).

See specifications for the [confirm NPQ participant declarations](/api-reference/reference-v1#api-v1-participant-declarations-post) endpoint.

### Provider records the NPQ participant declaration ID

Store the returned NPQ participant declaration ID for future management tasks.

## Removing a declaration submitted in error

This scenario begins when a provider needs to correct participant data that may have been submitted in error.

This operation allows the provider to void a declaration that has been previously submitted.

### Provider voids a declaration

Void an NPQ participant declaration

```
PUT /api/v1/participant-declarations/{id}/void
```

This will return a [participant declaration record](/api-reference/reference-v1#schema-participantdeclarationresponse) with the updates to the record included.

If providers void `completed` declarations where a participant had passed the assessment (`"has_passed": true`), then this outcome will also be retracted and the participants will be notified.

See specifications for the [void participant declaration](/api-reference/reference-v1#api-v1-participant-declarations-id-void-put) endpoint.

## Listing NPQ participant outcomes

This scenario begins after a provider has submitted a `completed` declaration for an NPQ participant and confirmed their outcome.

This operation allows the provider to view pass, fail or voided outcomes for NPQ participants.

### Provider views outcomes for an NPQ participant

View outcomes for a specific NPQ participant.

```
GET /api/v1/participant/npq/{participant_id}/outcomes
```

This will return an [NPQ outcomes response](/api-reference/reference-v1.html#schema-npqoutcomesresponse), including a `state` value to show: 

* outcomes submitted (`passed` or `failed)
* if the `completed` declaration has been voided and the outcome retracted (`voided`)

See specifications for the [participant outcome](/api-reference/reference-v1.html#api-v1-participants-npq-participant_id-outcomes-get) endpoint.

### Provider views outcomes for all NPQ participants

View outcomes for all NPQ participants.

```
GET /api/v1/participant/npq/outcomes
```

This will return an [NPQ outcomes response](/api-reference/reference-v1.html#schema-npqoutcomesresponse), including `state` values to show: 

* outcomes submitted (`passed` or `failed`)
* if any `completed` declarations have been voided and the outcomes retracted (`voided`)

See specifications for the [participant outcome](/api-reference/reference-v1.html#api-v1-participants-npq-outcomes-get) endpoint.

## Updating NPQ participant outcomes 

This scenario begins after a provider has submitted a `completed` declaration for a participant, including their course outcome.

This operation allows providers to update an NPQ participant's outcome. Providers can also view a list of all [previously submitted declarations](/api-reference/npq-usage.html#checking-all-previously-submitted-declarations).

Providers may need to update an outcome if the previously submitted data was inaccurate. For example, a provider should update the outcome if:
* the reported NPQ outcome was incorrect
* the reported date the participant received their outcome was incorrect
* a participant has retaken their NPQ assessment and their outcome has changed.

### Updating NPQ outcomes 

Submit an updated NPQ outcome.

```
POST /api/v1/participant/npq/{participant_id}/outcomes
```

The request body must contain all attributes described in the [NPQ participant outcome schema](/api-reference/reference-v3.html#schema-npqoutcomerequest-example), including updated values for the `completion_date` and `state` attributes.

This returns an [NPQ outcomes response](/api-reference/reference-v3.html#schema-npqoutcomeresponse) including updates to the record.

See specifications for the [NPQ outcomes](/api-reference/reference-v1.html#api-v1-participants-npq-participant_id-outcomes-post) endpoint. 