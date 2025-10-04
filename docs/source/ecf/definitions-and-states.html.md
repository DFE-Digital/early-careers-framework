---
title: Definitions and states
weight: 1
---

# Definitions and states

## Key concepts

| Concept      | Definition|
| -------- | --------  |
| `cohort`     | The grouping of participants who begin their induction or training in a given academic year under a given funding contract. For example, a participant who started their training in the 2024/25 academic year is assigned to the 2024 cohort. This is because funding for their training comes from the 2024/25 call-off contract. In most cases providers cannot change a participant’s cohort once they have started their training |
| `course_identifier`      | The participant’s training as either an early career teacher (ECT) or mentor       |
| `declaration`    | The notification submitted by providers via the API as the sole means for triggering output payments from DfE. Declarations are submitted where there is evidence of a participant’s engagement in training for a given milestone period      |
| `participant`    | An early career teacher (ECT) or mentor registered for training      |
| `partnership`     | The relationship created between schools, delivery partners and providers who work together to deliver early career training to participants      |
| `schedule`     | The expected timeframe in which a participant will complete their early career training. Schedules include [defined milestone dates](/api-reference/ecf/schedules-and-milestone-dates) against which DfE validates the declarations submitted by providers      |
| `statement`    | A record of output payments (based on declarations), service fees and any adjustments the DfE may pay lead providers at the end of a contractually agreed payment period. Statements sent to providers by DfE at the end of milestone periods can be used for invoicing purposes     |
| `unfunded-mentor` | Mentors linked to a provider's ECTs but not eligible for funding through that provider. Typically, these mentors have either completed, or are currently doing, mentor training with a different lead provider than the one delivering training to the ECT they support |

## API status values 

The API uses status values to describe the current state of partnerships, participants, and declarations. 
 
Each status tells providers what actions they can take through the API and what to expect from DfE. 

### Partnership statuses  

Partnership states are defined by the `status` attribute in partnership endpoint responses. 

Providers must [confirm their partnerships with schools](/api-reference/ecf/guidance/#confirm-view-and-update-partnerships) for each cohort. Once a partnership has been established the `status` value will become `active` and providers will receive participant information via the API. 

Schools can challenge existing partnerships at any time. Once a partnership `status` becomes `challenged`, providers will no longer be able to update partnership details. 

| `status` | Definition | Action |
| -------- | -------- | -------- |
| `active`     | A partnership between a provider, school and delivery partner has been agreed and confirmed by the provider    | Providers can view, confirm and update `active` partnerships     |
| `challenged`     | A partnership between a provider, school and delivery partner has been changed or dissolved by the school     | Providers can only view `challenged` partnerships    |

[View more detailed specifications for the partnerships schema](/api-reference/reference-v3.html#schema-ecfpartnershipattributes)

### Participant statuses 

The API uses two different status fields to describe a participant’s journey in the participant endpoints: 

* `training_status`, set by providers through the API. It determines what actions you can take, such as updating data or submitting declarations
* `participant_status`, set by schools through the 'Register early career teachers’ service. It reflects the participant’s position in the school (for example, joining, leaving, or withdrawn). 

Together, these statuses give both providers and schools a shared view of a participant’s training progress. 

#### Training status field

| `training_status` | Definition | Notes |
|-------------------|-------------|--------|
| `active` | Participant is currently in training | Update participant data and submit declarations |
| `deferred` | Participant has paused training | Providers must notify DfE when the participant restarts |
| `withdrawn` | Participant has left training | Cannot update participant data. Can only submit backdated declarations if `declaration_date` is before `withdrawal_date` |

#### Participant status field

| `participant_status` | Definition | Notes |
|----------------------|-------------|--------|
| `active` | Participant is currently training at the school | Matches the school’s latest confirmation |
| `joining` | Participant is due to join the school | Will update to **active** once the join date is reached |
| `leaving` | Participant is due to leave the school | Will update to **left** after the leaving date passes |
| `left` | Participant has left the school | No longer associated with the school |
| `withdrawn` | School has recorded that the participant has permanently left | May overlap with provider-recorded `training_status` |

Example of how the two participant statuses can differ: 

* a provider records a participant as `training_status = active` because they are still completing training
* at the same time, the school records the participant as `participant_status = leaving`, with a leaving date set for the end of term. 

In this case, the participant is still active in training, but their school has flagged that they are due to leave soon. Once the leaving date passes, the `participant_status` will update to `left`, while the provider will need to update the training record if the participant transfers or withdraws. 

[View more detailed specifications for the ECF participant schema](/api-reference/reference-v3.html#schema-ecfparticipantattributes)

## Declaration states

Declaration states are defined by the `state` attribute.

Providers must [submit declarations](/api-reference/ecf/guidance/#submit-view-and-void-declarations) to confirm a participant has engaged in training within a given milestone period. A declaration’s `state` value will reflect if and when DfE will pay providers for the training delivered.

| state | Definition | Action |
| -------- | -------- | -------- |
| `submitted`     | A declaration associated with to a participant who has not yet been confirmed to be eligible for funding    | Providers can view and void `submitted` declarations    |
| `eligible`     | A declaration associated with a participant who has been confirmed to be eligible for funding     | Providers can view and void `eligible` declarations    |
| `ineligible`     | A declaration associated with 1) a participant who is not eligible for funding 2) a duplicate submission for a given participant    | Providers can view and void `ineligible` declarations     |
| `payable`     | A declaration that has been approved and is ready for payment by DfE    | Providers can view and void `payable` declarations     |
| `voided`     | A declaration that has been retracted by a provider    | Providers can **only** view `voided` declarations   |
| `paid`     | A declaration that has been paid for by DfE    | Providers can view and void `paid` declarations     |
| `awaiting_clawback`     | A `paid` declaration that has since been voided by a provider    | Providers can **only** view `awaiting_clawback` declarations     |
| `clawed_back`     | An `awaiting_clawback` declaration that has since had its value deducted from payment by DfE to a provider     | Providers can **only** view `clawed_back` declarations     |

[View more detailed specifications for the declaration schema](/api-reference/reference-v3.html#schema-participantdeclarationattributes)

## IDs explained 

We use various unique identifiers (IDs) in the endpoint requests and responses to help make the API reliable, efficient, and unambiguous.  

| ID      | What the ID is for | 
| -------- | -------- | 
| `clawback_statement_id` | Identifies a clawback statement we’ve attached when funding paid to a lead provider needs to be returned due to overpayments or participant data changes (for example, someone withdraws from training or is found to be ineligible). Enables lead providers using the `declarations` endpoints  to identify which clawback statement a participant’s funding adjustment relates to and reconcile clawbacks against their monthly or cumulative funding reports | 
| `declaration_id` | Created when providers submit a declaration. This ID can also be used to void a declaration. It’s shown as simply `id` at the top of successful responses in the `declarations` endpoints | 
| `delivery_partner_id` | Identifies delivery partners. Used when providers form partnerships as part of the `POST partnerships` endpoint. It’s also listed in `GET participants/ecf` and `GET participants/ecf/{id}` responses in API v3 | 
| `mentor_id` | Identifies individual ECT mentors within the API. This ID is used to link mentors to ECTs they’re supporting, and tracks their training status, funding eligibility, and contact information. The same `mentor_id` is used whether the mentor is funded or unfunded, including those trained by a different lead provider than the one supporting their ECT | 
| `participant_id` | Identifies participants registered for training. This is used for declarations, changing schedules, notifying us of a change in circumstances related to their training as well as other endpoints to monitor training and progress | 
| `participant_id_changes` | A record of changes where a participant’s ID has been updated, usually to fix a data issue like a duplicate or incorrect registration. In such cases, the `from_participant_id` field is the original ID that has been retired or replaced. The `to_participant_id` is the new ID that should now be used when referring to this participant | 
| `partnership_id` | Identifies the partnership between schools, delivery partners and providers for a specific cohort who work together to deliver training to participants. It’s shown as simply `id` at the top of successful responses in the `partnership` endpoints | 
| `statement_id` | Identifies a financial statement we've attached to a lead provider. It acts as a reference for each individual payment cycle or statement and allows lead providers to retrieve financial data using the `GET statements` endpoints | 
| `school_id` | Identifies schools. Used when providers form partnerships as part of the `POST partnerships` endpoint | 
| `training_record_id` | Identifies participants with multiple enrolments, such as an ECT who later becomes a mentor. Providers using the `participants` endpoints will see separate records for the same participant, each with a different `training_record_id` based on their role | 
