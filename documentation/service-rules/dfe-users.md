---
title: Department for Education staff
---

The goal for ECF 2 is that the application will be self-sustainable. That means
developers shouldn't be needed in the everyday operation of the application.

This list contains the responsibilities developers have now, but should be
made available via the admin interface in ECF 2:

- The DfE has previously advised of the possibility that participants
  may be registered as duplicates with multiple `participant_ids`. Where
  the DfE identifies duplicates, it will fix the error by 'retiring'
  one of the participant IDs, then associating all records and data
  under the remaining ID.
- Manual process for merging, closing or opening schools which greatly
  depends on things like whether the school has a successor,
  participants etc - and what training programme they've
  selected
- If the ECT doesn't have an induction start date recorded, they are
  assigned a temporary cohort to enable access training while the AB
  has not yet recorded their induction start date
- Replacement mentors
- Cohort allocation
- [Eligibility for funding](https://teacher-cpd.design-history.education.gov.uk/manage-training/iterations-to-eligibility-checks/)
- Syncing our school list with GIAS
- Sending out reminder emails -- manual or scheduled comms
- Checking eligibility
- Setting up cohorts & schedules
- Assigning participants to a cohort temporarily or permanently
- Setting or updating participant statuses
- Calculating grant funding

## Calculating payments for providers

What is referred to as the 'payment engine' is a piece of code in the
same ECF application that calculates payments for LPs.

[Provider payments are made up of a]([Provider payments are made up of](https://educationgovuk.sharepoint.com/:w:/s/TeacherServices/ERtdlODXiLBFlEVBMLPSL6cBJno1HDIK-Zfdn9bS1ZuE-g?e=ORWQ3p):

- set-up fee
- service fee
- uplift fee
- output payment

To calculate the payment we need to know the:

- participant recruitment target
- volume banded price per participant
- actual number of participants declared at each milestone
- number of declared participants eligible for uplift

The per-participant price is usually paid 60% via output fee & 40% via
service fee.

Financial statements are produced and paid monthly. As well as the
calculated payment amount, the financial statements include:

- Additional adjustments
- Clawbacks
- VAT

Financial statements are viewable by any internal DfE member with
'finance access'. Users will see an 'Authorise for payment' button
underneath the summary on the financial statements that include output
fees and where the deadline date has passed. This allows them to
'freeze' the statement and conduct their assurance tasks on a statement
without the numbers on the statement changing. It transitions eligible
declarations from the 'payable' state to the 'paid' state. This blocks
providers from being able to void those declarations. If a void does
happen after this point it is clawed back, rather than voided. Once the
statement has been authorised for payment It also places a tag on the
relevant financial statement showing the time and day the statement was
authorised 'e.g. Authorised for payment at 10:30am on 5 Aug 2023'.

A Statement can have different types of declarations:

 | State               | Definition                                                                                                                    | Action                                                   |
 | -----               | ----------                                                                                                                    | ------                                                   |
 | `submitted`         | A declaration associated with a participant who has not yet been confirmed to be eligible for funding                         | Providers can view and void `submitted` declarations     |
 | `eligible`          | A declaration associated with a participant who has been confirmed eligible for funding                                       | Providers can view and void `eligible` declarations      |
 | `ineligble`         | A declaration associated with a participant who is not eligible for funding or a duplicate submission for a given participant | Providers can view and void `ineligible` declarations    |
 | `payable`           | A declaration that has been approved and is ready for payment by DfE                                                          | Providers can view and void `payable` declarations       |
 | `voided`            | A declaration that has been retracted by a provider                                                                           | Providers can only view `voided` declarations            |
 | `paid`              | A declaration that has been paid by DfE                                                                                       | Providers can view and void `paid` declarations          |
 | `awaiting_clawback` | A `paid` declaration that has since been voided by a provider                                                                 | Providers can only view `awaiting_clawback` declarations |
 | `clawed_back`       | An `awaiting_clawback` declaration that has had its value deducted from payment by DfE to a provider                          | Providers can only view `clawed_back` declarations       |

Audit trail -- not visible but exists

Contract managers can download a copy of the statement and a list of the
submitted declarations within it to share with providers. Providers can
see the information in the statement via API v3.

### ECF volume banded prices

Each provider is required to specify a target recruitment number for
participants and quote volume banded prices.

- There were originally 3 bands.
- Each band must have a lower price-per-participant than the previous
  band.
- Volume banded pricing is applied to both service fee and output fee.

Band D was introduced when the government made more funding available
for ECF and the DfE invited lead providers to increase their recruitment
targets.

- Band D is paid the same per-participant price as Band C.
- For Band D 100% of the per-participant price is paid via output fee.
  There is no service fee component.
- Some providers don't have a Band D

### Set-up fee

The set-up fee is an amount that providers can claim to cover the costs
of standing up the service. It is effectively an advance. The maximum is
£150k.

The set up fee is paid by being added into the service fee for Band A
participants:

- We have a set figure we've agreed to pay providers for set up costs.
- We take that amount and divide it by the amount of months in the
  contract.
- Then we take that monthly payment and divide it by the amount of
  **target** participants in band A.
- We adjust the service fee for Band A participants so that it
  reflects service fee + set-up fee combined.

Note, in some cases where LPs are underperforming the target number of
participants may be updated, which impacts the set up fee.

### Service fees

Service fees are a fixed amount paid monthly and are based on the
recruitment target, not the number of participants actually recruited.
Contract management provide the total contract value and length and the
service fee amount is determined by dividing 60% of the contract value
by the contract length.

It is calculated as 40% of the banded per participant price, multiplied
by the **target** participants per band, divided by the number of months
of the contract.

Source: Contract management provide total contract value and length.
Amount is determined by 60% of the contract value divided by contract
length.

[See Schedule 7 - Pricing and performance table 3b](https://github.com/DFE-Digital/ecf2/blob/main/documentation/providers/nro-framework-level-agreement-redacted-v1.1.adoc#schedule-7--pricing-and-performance).

### Uplift fees

The uplift fee is a bonus that is paid to providers for recruiting
participants from schools in deprived areas.

-   It is £100 per eligible participant that receives a Started
    declaration.
-   It is paid as a single payment at the first milestone.
-   Eligibility is determined by the participant's school's score for
    sparsity and pupil premium (updated before opening registrations
    each year).
-   Although a participant may be eligible for both pupil premium (£100)
    and sparsity uplift (£100) payments, they will only receive a £100
    payment in total.

### Output fees

The output payment is a variable amount paid according to schedule
milestone dates. There are typically 6 output payments (according to a
standard schedule).

- It is based on the number of declared participants, not the
  recruitment target.
- It is calculated as 60% of the banded participant price, multiplied
  by the participants per band, multiplied by the milestone weighting.
- Started and completed milestones are weighted at 20%, the 4 retained
  milestones at 15% each.

When a provider submits a declaration for a participant, there is
validation to check that:

- The declaration has been submitted at the right time according to
  the participant's schedule, i.e. within the right milestone period
  (note, this could be backdated)
- The participant is eligible for funding, i.e. funding status = true
- The same declaration has not already been submitted for the
  participant

If any of these checks fail, the declaration is stored as ineligible and
is not assigned to a financial statement.

If these validation checks are passed, the provider's contract for the
academic year ('cohort' / funding pot) is referenced to check:

- The value of the declaration for the participant
- Whether the participant has any additional associated uplifts
- The banding the participant should be assigned to
- Whether the count of declarations is below the LP's recruitment
  target, i.e. below the maximum number of declarations allowed for
  the contract

Based on these details, the output fee amount is calculated and added to
the next available statement.

### Manual adjustments

There are some one-off additional payments added to financial statements
(e.g. IT service charges). These are added manually by contract
managers, outside of the calculation. Contract managers enter this in a
field in the finance tool.

### Clawbacks

DfE can claim back money from providers via clawbacks. If money was paid
in error and declarations are voided, rather than DfE expecting LPs to
pay the money back in a separate process - we deduct the amount due from
the amount to be paid on the financial statement. Clawbacks cover the
different declaration types (e.g. started, retained 1 etc) and uplift.
