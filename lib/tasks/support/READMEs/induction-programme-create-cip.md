# `rails support:induction_programmes:cip:find_or_create`

This task finds or creates a CIP induction programme for a given school cohort.

## Usage

```bash
rails support:induction_programmes:cip:find_or_create[school_urn,cohort_year,cip_name]
```

### Arguments

- `school_urn` - The URN of the school to find or create the CIP induction programme for.
- `cohort_year` - The cohort year of the CIP induction programme.
- `cip_name` - The name of the CIP induction programme.

### Dry Run

```bash
rails support:induction_programmes:cip:find_or_create_dry_run[school_urn,cohort_year,cip_name]
```
