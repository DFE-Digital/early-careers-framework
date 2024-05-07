# Support Rake tasks

This directory contains Rake tasks that are used to quickly perform common tasks related to support queries.

All support tasks support a dry run alternative that will output the changes that would be made without actually making them.

## `rake support:participants:reactivate:run`

This task reactivates a given participant profile. It does this by marking four attributes as active:
- participant_profile -> *status*
- participant_profile -> *induction_status*
- participant_profile -> latest_induction_record -> *training_status*
- participant_profile -> latest_induction_record -> *induction_status*

This task is useful when a participant has been deactivated and needs to be reactivated.

### Usage

```bash
rails support:participants:reactivate:run[participant_id]
```

#### Arguments

- `participant_id` - The ID of the participant to reactivate.

#### Dry Run

```bash
rails support:participants:reactivate:dry_run[participant_id]
```

## `rake support:participants:mentors:withdraw:run`

This task withdraws a mentor from a school. It does this by removing their school_mentor record and marking their participant_profile as withdrawn.

This task is useful when a mentor is no longer mentoring at a school.

### Usage

```bash
rails support:participants:mentors:withdraw:run[participant_id, school_urn]
```

#### Arguments

- `participant_id` - The ID of the mentor to withdraw.
- `school_urn` - The URN of the school to withdraw the mentor from.

#### Dry Run

```bash
rails support:participants:mentors:withdraw:dry_run[participant_id, school_urn]
```
