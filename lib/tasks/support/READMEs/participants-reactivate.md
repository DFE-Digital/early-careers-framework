# `rails support:participants:reactivate:run`

This task reactivates a given participant profile. It does this by marking four attributes as active:
- participant_profile -> *status*
- participant_profile -> *induction_status*
- participant_profile -> latest_induction_record -> *training_status*
- participant_profile -> latest_induction_record -> *induction_status*

This task is useful when a participant has been deactivated and needs to be reactivated.

## Usage

```bash
rails support:participants:reactivate:run[participant_id]
```

### Arguments

- `participant_id` - The ID of the participant to reactivate.

### Dry Run

```bash
rails support:participants:reactivate:dry_run[participant_id]
```
