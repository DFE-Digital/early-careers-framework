---
title: Schedules and milestone dates
---

# Schedules and milestone dates

Lorem ipsum dolor sit amet, officia excepteur ex fugiat reprehenderit enim
labore culpa sint ad nisi Lorem pariatur mollit ex esse exercitation amet. Nisi
anim cupidatat excepteur officia. Reprehenderit nostrud nostrud ipsum Lorem est
aliquip amet voluptate voluptate dolor minim nulla est proident. Nostrud
officia pariatur ut officia. Sit irure elit esse ea nulla sunt ex occaecat
reprehenderit commodo officia dolor Lorem duis laboris cupidatat officia
voluptate. Culpa proident adipisicing id nulla nisi laboris ex in Lorem sunt
duis officia eiusmod. Aliqua reprehenderit commodo ex non excepteur duis sunt
velit enim. Voluptate laboris sint cupidatat ullamco ut ea consectetur et est
culpa et culpa duis.


### Standard induction

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
