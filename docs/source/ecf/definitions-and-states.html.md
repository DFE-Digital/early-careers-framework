---
title: Definitions and states
weight: 1
---

# Definitions and states

## Key concepts

| Concept      | Definition|
| -------- | --------  |
| `participant`    | An early career teacher (ECT) or mentor registered for training      |
| `cohort`     | The grouping of participants who begin their induction or training in a given academic year under a given funding contract. For example, a participant starting their training in the academic year 2021-22 will have a cohort of 2021, as funding comes from the 2021-22 call-off contract. In most cases providers cannot change a participant’s cohort once they have begun their training      |
| `schedule`     | The expected timeframe in which a participant will complete their ECF-based training. Schedules include [defined milestone dates](/api-reference/ecf/schedules-and-milestone-dates) against which DfE validates the declarations submitted by providers      |
| `course_identifier`      | The participant’s training as either an early career teacher (ECT) or mentor       |
| `declaration`    | The notification submitted by providers via the API as the sole means for triggering output payments from DfE. Declarations are submitted where there is evidence of a participant’s engagement in training for a given milestone period      |
| `partnership`     | The relationship created between schools, delivery partners and providers who work together to deliver ECF-based training to participants      |
| `statement`    | A record of output payments (based on declarations), service fees and any adjustments the DfE may pay lead providers at the end of a contractually agreed payment period. Statements sent to providers by DfE at the end of milestone periods can be used for invoicing purposes     |

## Data states and what they mean

The API service uses a ‘state’ model to reflect the ECF participant journey, meet contractual requirements for how providers should report participants’ training and how the DfE will pay for this training.

### Participant states

Participant states are defined by the `training_status` attribute. 

A participant’s `training_status` value will determine whether a provider can: 

* [update their details](/api-reference/ecf/guidance/#view-and-update-participant-data). For example, notifying DfE that a participant has withdrawn from training 
* [submit a declaration](/api-reference/ecf/guidance/#submit-view-and-void-declarations). For example, notifying DfE that a participant has started their training


| training_status | Definition | Action |
| -------- | -------- | -------- |
| `active`     | Participants currently in training     | Providers can update participant data and submit declarations for `active` participants     |
| `deferred`     | Participants who have deferred training     | Providers **cannot** update participant data or submit declarations for `deferred` participants. Providers must [notify DfE when the participant resumes training](/api-reference/ecf/guidance/#notify-dfe-a-participant-has-resumed-training)     |
| `withdrawn`     | Participants who have withdrawn from training     | Providers **cannot** update participant data for `withdrawn` participants. Providers can **only** submit declarations for `withdrawn` participants if the `declaration_date` is backdated to before the `withdrawal_date`     |

View more detailed specifications for the [ECF participant schema](/api-reference/reference-v3.html#schema-ecfparticipantattributes).

### Declaration states

Declaration states are defined by the `state` attribute. 

Providers must [submit declarations](/api-reference/ecf/guidance/#submit-view-and-void-declarations) to confirm a participant has engaged in training within a given milestone period. A declaration’s `state` value will reflect if and when the DfE will pay providers for the training delivered.

| state | Definition | Action |
| -------- | -------- | -------- |
| `submitted`     | A declaration associated with to a participant who has not yet been confirmed to be eligible for funding    | Providers can submit, view and void `submitted` declarations    |
| `eligible`     | A declaration associated with a participant who has been confirmed to be eligible for funding     | Providers can view and void `eligible` declarations    |
| `ineligible`     | A declaration associated with 1) a participant who is not eligible for funding 2) a duplicate submission for a given participant    | Providers can view and void `ineligible` declarations     |
| `payable`     | A declaration that has been approved and is ready for payment by DfE    | Providers can view and void `payable` declarations     |
| `voided`     | A declaration that has been retracted by a provider    | Providers can **only** view `voided` declarations   |
| `paid`     | A declaration that has been paid for by DfE    | Providers can view and void `paid` declarations     |
| `awaiting_clawback`     | A `paid` declaration that has since been voided by a provider    | Providers can **only** view `awaiting_clawback` declarations     |
| `clawed_back`     | An `awaiting_clawback` declaration that has since had its value deducted from payment by DfE to a provider     | Providers can **only** view `clawed_back` declarations     |


View more detailed specifications for the [declaration schema](/api-reference/reference-v3.html#schema-ecfparticipantdeclarationattributes).


### Partnership states 

Partnership states are defined by the `status` attribute. 

Providers must [confirm their partnerships with schools](/api-reference/ecf/guidance/#confirm-view-and-update-partnerships) for each cohort. Once a partnership has been established the `status` value will become `active` and providers will receive participant information via the API.

Schools can challenge existing partnerships at any time. Once a partnership `status` becomes `challenged`, providers will no longer be able to update partnership details.

| status | Definition | Action |
| -------- | -------- | -------- |
| `active`     | A partnership between a provider, school and delivery partner has been agreed and confirmed by the provider    | Providers can view, confirm and update `active` partnerships     |
| `challenged`     | A partnership between a provider, school and delivery partner has been changed or dissolved by the school     | Providers can **only** view `challenged` partnerships    |

View more detailed specifications for the [partnerships schema](/api-reference/reference-v3.html#schema-ecfpartnershipattributes).