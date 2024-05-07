# `rails support:participants:induction_programmes:transfer:run`

This task is used to transfer a participant from one induction programme to another.

## Usage

```bash
rails support:participants:induction_programmes:transfer:run[participant_id,induction_programme_id]
```

### Arguments

- `participant_id` - The ID of the participant to transfer.
- `induction_programme_id` - The ID of the induction programme to transfer the participant to.

### Dry Run

```bash
rails support:participants:induction_programmes:transfer:dry_run[participant_id,induction_programme_id]
```
