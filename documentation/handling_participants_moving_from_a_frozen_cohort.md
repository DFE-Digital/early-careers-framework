# Handling participants moving from a cohort frozen for payments to the active cohort

To enable the 2021 cohort to be frozen for payments, participants that had not completed their induction could be moved to the 2024 cohort by following these steps in order:

1. A change happens to the participant such as changing from `withdrawn` to `active` status, transferring to another school or a change of mentor or mentee that indicate they are continuing with their training
2. We verify that the participant is eligible to move
3. We move the participant

These will happen automatically for school transfers, mentor assignments, re-validations and the move will be performed when possible.

## How do I determine whether the participant is eligible to move?

In addition to seeing that they are continuing with training, we need to check the participant's induction status and declarations to determine whether they are eligible to move from 2021 to 2024:

```ruby
participant_profile.eligible_to_change_cohort_and_continue_training?(cohort:)
```

Where `cohort` is `Cohort.active_registration_cohort`

## How do I move a 2021 participant to 2024?

Once we are sure that a participant is eligible to be moved from 2021 to 2024 we use the `Induction::AmendParticipantCohort` service.  This performs lots of validations and safeguards that should not be skipped or performed manually.

```ruby
i = Induction::AmendParticipantCohort.new(participant_profile:,
                                          source_cohort_start_year: 2021,
                                          target_cohort_start_year: 2024)
i.save
```

If the result is `false` then `i.errors.messages` will contain the validations that have failed and the participant will not have moved.

Going forward we should replace instances of 2021 with the cohort that is frozen for payments and 2024 with `Cohort.active_registration_cohort`
