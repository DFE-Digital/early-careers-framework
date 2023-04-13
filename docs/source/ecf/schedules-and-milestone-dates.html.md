---
title: Schedules and milestone dates
---

# Schedules and milestone dates

The DfE makes payment to providers in line with agreed contractual schedules and training criteria. 

Providers are paid a proportionate sum of money relative to the amount of time they support their participants.

Providers must [submit declarations](LINK NEEDED) ahead of milestone dates (deadlines) to ensure payments are made for a given milestone. 

## Key definitions

| Concept      | Definition| 
| -------- | --------  |
| Schedule    | The expected timeframe in which a participant will complete their ECF-based training, which determine the defined milestone dates      |
| Standard schedule  | For participants completing the standard 2 year induction, starting in September, January or April  |
| Extended schedule   | A non-standard schedule for participants who expect to complete the induction over a period greater than 2 years. Examples include part-time ECTs, or ECTs whose induction period is extended by their appropriate body  |
| Reduced schedule   | A non-standard schedule for participants who expect to complete the induction over a period less than 2 years, e.g. those with previous experience  |
| Replacement schedule  | A non-standard schedule for mentors that are replacing a previous mentor for an ECT that is part way through their training  |
| Milestone   | Contractual periods of ECF-based training delivery during which providers must submit relevant declarations evidencing participant retention      |
| Milestone dates    | The deadline date a valid declaration can be made for a given milestone in order for the DfE to be liable to make a payment the following month. Milestone dates are dependent on the participant’s schedule       |
| Milestone period    | The period of time between the milestone start date and deadline date       |
| Payment date    | The date the DfE will make payment for valid declarations submitted by providers for a given milestone     |



## Standard induction

A usual 2 year induction covers 6 terms (3 in each academic year). The payment model for those following a standard induction is therefore equal to 1 milestone payment for each of the 6 terms you are supporting a participant. We are allowing functionality for providers to switch participants onto the following standard schedules:

* `ecf-standard-september`
* `ecf-standard-january`
* `ecf-standard-april`

Standard schedules will be subject to milestone validation as outlined in the tables below.

### Standard induction starting in September
Participants should be tagged as `ecf-standard-september` if they are starting their course before the **30 November 2021** and are expected to complete their training over two academic years.

| Retention Point                         | Milestone Date      | Payment Made       |
| --------------------------------------- | ------------------- | ------------------ |
| Output 1 - Participant Start (20%)      | 30th November 2021  | 30th November 2021 |
| Output 2 – Retention Point 1 (15%)      | 31st January 2022   | 28th February 2022 |
| Output 3 – Retention Point 2 (15%)      | 30th April 2022     | 31st May 2022      |
| Output 4 – Retention Point 3 (15%)      | 30th September 2022 | 31st October 2022  |
| Output 5 – Retention Point 4 (15%)      | 31st January 2023   | 28th February 2023 |
| Output 6 – Participant Completion (20%) | 30th April 2023     | 31st May 2023      |

### Standard induction starting in January
Participants should be tagged as `ecf-standard-january` if they are starting their course on or after **1 December** and are expected to complete their training over 2 years.

| Retention Point                         | Milestone Date      | Payment Made       |
| --------------------------------------- | ------------------- | ------------------ |
| Output 1 - Participant Start (20%)      | 31st January 2022   | 28th February 2022 |
| Output 2 – Retention Point 1 (15%)      | 30th April 2022     | 31st May 2022      |
| Output 3 – Retention Point 2 (15%)      | 30th September 2022 | 31st October 2022  |
| Output 4 – Retention Point 3 (15%)      | 31st January 2023   | 28th February 2023 |
| Output 5 – Retention Point 4 (15%)      | 30th April 2023     | 31st May 2023      |
| Output 6 – Participant Completion (20%) | 31st October 2023   | 30th November 2023 |

### Standard induction starting in April

Participants should be tagged as `ecf-standard-april` if they are starting their course on or after **1 February** and are expected to complete their training over 2 years.

| Retention Point                         | Milestone Date      | Payment Made       |
| --------------------------------------- | ------------------- | ------------------ |
| Output 1 - Participant Start (20%)      | 30th April 2022     | 31st May 2022      |
| Output 2 – Retention Point 1 (15%)      | 30th September 2022 | 31st October 2022  |
| Output 3 – Retention Point 2 (15%)      | 31st January 2023   | 28th February 2023 |
| Output 4 – Retention Point 3 (15%)      | 30th April 2023     | 31st May 2023      |
| Output 5 – Retention Point 4 (15%)      | 31st October 2023   | 30th November 2023 |
| Output 6 – Participant Completion (20%) | 31st January 2024   | 28th February 2024 |


### Non-standard induction
Following the same principles of those on a standard induction, providers will be paid the equivalent of one milestone payment for each of the terms they are supporting a participant. Non-standard schedules will not be subject to milestone validation.

Under a non-standard schedule, the API will accept any declarations once the first milestone period for the schedule has started. For example, if a participant is on an ecf-extended-september schedule, the API will accept any type of declaration, such as a start, retention-1 or completion, from 1 September 2021. Providers will still be expected to evidence any declarations and why a participant is following a non-standard induction.

We are allowing functionality for providers to switch participants onto the following non-standard schedules:

* `ecf-extended-september`
* `ecf-extended-january`
* `ecf-extended-april`
* `ecf-reduced-september`
* `ecf-reduced-january`
* `ecf-reduced-april`
* `ecf-replacement-september`
* `cf-replacement-january`
* `ecf-replacement-april`

The non-standard induction schedules are detailed below.

### Extended schedule
For participants that expect to complete their induction over a period greater than two years, with the schedule reflecting the month when the participant starts. For example, part time ECTs:

* `ecf-extended-september`
* `ecf-extended-january`
* `ecf-extended-april`

### Reduced schedule
For participants that expect to complete their induction over a period less than 2 years, with the schedule reflecting the month when the participant starts:

* `ecf-reduced-september`
* `ecf-reduced-january`
* `ecf-reduced-april`

### Replacement mentors
For mentors that are replacing a mentor for an ECT that is part way through their training with the schedule reflecting the month when the replacement starts:

* `ecf-replacement-september`
* `ecf-replacement-january`
* `ecf-replacement-april`

Where a mentor is already mentoring an ECT and they replace a mentor for a second ECT, the first ECT takes precedence. In this instance, the provider should not change the mentor’s schedule.

The DfE expects that a replacement mentor's training, and therefore any declarations a provider submits for them, will align with the ECT they are mentoring. Say a replacement mentor begins mentoring an ECT part way through the ECT’s induction. The provider has already submitted a start declaration for the previous mentor. Now, the provider makes a retention-1 declaration for the ECT. The department would expect that any declaration made for the replacement mentor in the same milestone period as that made for the ECT would also be a retention-1 declaration.
