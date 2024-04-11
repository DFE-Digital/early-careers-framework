# `rails support:participants:mentors:withdraw:run`

This task removes a mentor from a school. It does this by removing their school_mentor record and marking their participant_profile as withdrawn.

This task is useful when a mentor has been added to the wrong school and needs to be removed.

## Usage

```bash
rails support:participants:mentors:withdraw:run[participant_id, school_urn]
```

### Arguments

- `participant_id` - The ID of the mentor to remove.
- `school_urn` - The URN of the school to remove the mentor from.

### Dry Run

```bash
rails support:participants:mentors:remove:dry_run[participant_id, school_urn]
```
