---
title: Definitions and states
weight: 1
---

# Definitions and states

## Key concepts

| Concept      | Definition|
| -------- | --------  |
| `application`    | The application a person makes to be trained on an NPQ course. Applications include funding details       |
| `participant`    | A person registered for an NPQ course      |
| `cohort`     | The grouping of participants who begin their course in a given academic year under a given funding contract. For example, a participant starting their training in the academic year 2021-22 will have a cohort of 2021, as funding comes from the 2021-22 call-off contract. In most cases providers cannot change a participant’s cohort once they have begun their training      |
| `schedule`     | The expected timeframe in which a participant will complete their NPQ course. Schedules include [defined milestone dates](/api-reference/npq/schedules-and-milestone-dates) against which DfE validates the declarations submitted by providers      |
| `course_identifier`      | The NPQ course a person applies for, and a participant is registered for      |
| outcome`      | The assessment result a participant achieves a the end of an NPQ course      |
| `declaration`    | The notification submitted by providers via the API as the sole means for triggering output payments from DfE. Declarations are submitted where there is evidence of a participant’s engagement in training for a given milestone period      |
| `statement`    | A record of output payments (based on declarations), service fees and any adjustments the DfE may pay lead providers at the end of a contractually agreed payment period. Statements sent to providers by DfE at the end of milestone periods can be used for invoicing purposes     |

### Participant states

Participant states are defined by the `training_status` attribute. 

A participant’s `training_status` value will determine whether a provider can: 

* [update their details](/api-reference/npq/guidance/#view-and-update-participant-data). For example, notifying DfE that a participant has withdrawn from the course 
* [submit a declaration](/api-reference/npq/guidance/#submit-view-and-void-declarations). For example, notifying DfE that a participant has started their training

| training_status | Definition | Action |
| -------- | -------- | -------- |
| `active`     | Participants currently in training     | Providers can update participant data and submit declarations for `active` participants     |
| `deferred`     | Participants who have deferred training     | Providers **cannot** update participant data or submit declarations for `deferred` participants. Providers must [notify DfE when the participant resumes training](/api-reference/ecf/guidance/#notify-dfe-a-participant-has-resumed-training)     |
| `withdrawn`     | Participants who have withdrawn from training     | Providers **cannot** update participant data for `withdrawn` participants. Providers can **only** submit declarations for `withdrawn` participants if the `declaration_date` is backdated to before the `withdrawal_date`     |
| `completed`     | Participants who have withdrawn from training     | Providers **cannot** update participant data or submit declarations for `completed` participants    |

View more detailed specifications for the [NPQ participant schema](/api-reference/reference-v3.html#schema-npqparticipant).

