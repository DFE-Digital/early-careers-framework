---
title: Definitions and states
---

# Definitions and states

## Key definitions

The API sends and receives data from: 

* lead providers
* delivery partners
* schools
* participants
* DfE


| Concept      | Definition| Action |
| -------- | --------  | -------- |
| `participant`    | An early career teacher (ECT) or mentor registered for training      | [View and update participant data](LINK NEEDED)     |
| `cohort`     | The grouping of participants who begin their induction or training in a given academic year under a given funding contract. For example, a participant starting their training in the academic year 2021-22 will have a cohort of 2021, as funding comes from the 2021-22 call-off contract      | In most cases providers cannot change a participant’s cohort once they have begun their training     |
| `schedule`     | The expected timeframe in which a participant will complete their ECF-based training. Schedules include [defined milestone dates](LINK NEEDED) against which DfE validates the declarations submitted by providers      | [View and update participant data](LINK NEEDED)      |
| `course_identifier`      | The participant’s training as either an early career teacher (ECT) or mentor       | [View and update participant data](LINK NEEDED)      |
| `declaration`    | The notification submitted by providers via the API as the sole means for triggering output payments from DfE. Declarations are submitted where there is evidence of a participant’s engagement in training for a given milestone period      | [How to submit, view and void declarations](LINK NEEDED)    |
| `partnership`     | The relationship created between schools, delivery partners and providers who work together to deliver ECF-based training to participants      | [How to view and submit partnerships with schools and delivery partners](LINK NEEDED)     |
| statement    | A record of output payments (based on declarations), service fees and any adjustments the DfE may pay lead providers at the end of a contractually agreed payment period      | Statements sent to providers by DfE at the end of milestone periods can be used for invoicing purposes     |

## Data states and what they mean

The API service uses a ‘state’ model to reflect the ECF participant journey, meet contractual requirements for how providers should report participants’ training and how the DfE will pay for this training.

### Participant states

Participant states are defined by the `training_status` attribute. 

A participant’s `training_status` value will determine whether a provider can: 
* update their details. For example, notifying DfE that a participant has withdrawn from training 
* submit a declaration. For example, notifying DfE that a participant has completed their training


| `training_status` | Definition | Action |
| -------- | -------- | -------- |
| `active`     | Participants currently in training     | Providers can 1. [update participant data](LINK NEEDED). For example, notifying DfE they have withdrawn 2. [submit declarations](LINK NEEDED). For example, notifying DfE they have completed training     |
| `deferred`     | Participants who have deferred training     | Providers cannot submit declarations for `deferred` participants. Providers must [notify DfE when the participant resumes training](LINK NEEDED)     |
| `withdrawn`     | Participants who have withdrawn from training     | Providers cannot update participant data for `withdrawn` participants. Providers can **only** submit declarations for `withdrawn` participants if the `declaration_date` is backdated to before the `withdrawal_date`     |
| `completed`     [TCBC FOR V3!]| Participants who have completed training     | Providers cannot make updates to `completed` participant data or submit any further declarations for them     |

Find more detailed specifications in the [ECF participant schema](/api-reference/reference-v1.html#schema-ecfparticipantattributes).

### Declaration states

Declaration states are defined by the `state` attribute. 

Providers must submit declarations via the API to confirm a participant has engaged in training within a given milestone period. A declaration’s `state` value will reflect if and when the DfE will pay providers for the training delivered to this participant.

| `state` | Definition | Action |
| -------- | -------- | -------- |
| `submitted`     | A declaration associated with to a participant who has not yet been confirmed to be eligible for funding    | Providers can [submit, view and void declarations](LINK NEEDED)     |
| `eligible`     | A declaration associated with a participant who has been confirmed to be eligible for funding     | Providers can [view and void declarations](LINK NEEDED)    |
| `ineligible`     | A declaration associated with 1) a participant who is not eligible for funding 2) a duplicate submission for a given participant    | [Providers can [view and void declarations](LINK NEEDED)     |
| `payable`     | A declaration that has been approved and is ready for payment by DfE    | Providers can [view and void declarations](LINK NEEDED)     |
| `voided`     | A declaration that has been retracted by a provider    | Providers can [view declarations](LINK NEEDED)    |
| `paid`     | A declaration that has been paid for by DfE    | [How to submit, view and void declarations](LINK NEEDED)     |
| `awaiting_clawback`     | A `paid` declaration that has since been voided by a provider    | Providers can [view and void declarations](LINK NEEDED)     |
| `clawed_back`     | An `awaiting_clawback` declaration that has since had its value deducted from payment by DfE to a provider     | Providers can [view and void declarations](LINK NEEDED)     |


Find more detailed specifications in the [declaration schema](/api-reference/reference-v1.html#schema-participantdeclarationattributes).


### Partnership states 

Partnership states are defined by the `status` attribute. 

Providers must confirm partnerships with schools for each cohort via the API. Once a partnership has been established the `status` value will reflect this and providers will have access to participant information via the API.

| `status` | Definition | Action |
| -------- | -------- | -------- |
| `active`     | A partnership between a provider, school and delivery partner has been agreed and confirmed by the provider    | Providers can [view and confirm partnerships](LINK NEEDED)     |
| `challenged`     | A partnership between a provider, school and delivery partner has been changed or dissolved by the school     | Providers can [view and confirm partnerships](LINK NEEDED)    |

Find more detailed specifications in the [partnerships schema](/api-reference/reference-v3.html#schema-ecfpartnershipattributes).