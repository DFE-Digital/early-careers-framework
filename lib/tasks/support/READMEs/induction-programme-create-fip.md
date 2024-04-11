# `rails support:induction_programmes:fip:find_or_create`

This task finds or creates a FIP induction programme for a given school cohort.

## Usage

```bash
rails support:induction_programmes:fip:find_or_create[school_urn cohort_year lead_provider_name delivery_partner_name]
```

### Arguments

- `school_urn` - The URN of the school to find or create the FIP induction programme for.
- `cohort_year` - The cohort year of the FIP induction programme.
- `lead_provider_name` - The name of the lead provider for the FIP induction programme.
- `delivery_partner_name` - The name of the delivery partner for the FIP induction programme.

### Dry Run

```bash
rails support:induction_programmes:fip:find_or_create_dry_run[school_urn cohort_year lead_provider_name delivery_partner_name]
```
