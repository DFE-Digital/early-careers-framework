\copy (
  with everything as (
    select
      s.urn,
      sc.induction_programme_choice,
      (p.id is not null)              as in_partnership,
      lp.name                         as lead_provider_name,
      dp.name                         as delivery_partner_name,
      c.start_year                    as cohort

    FROM schools s

    left outer join school_cohorts sc on s.id = sc.school_id
    left outer join cohorts c on sc.cohort_id = c.id
    left outer join partnerships p on s.id = p.school_id and c.id = p.cohort_id
    left outer join lead_providers lp on p.lead_provider_id = lp.id
    left outer join delivery_partners dp on p.delivery_partner_id = dp.id

    where (c.start_year > 2020 or c.id is null)
  ),
  just_2021 as (
    select *
    from everything
    where cohort = 2021
  ),
  just_2022 as (
    select *
    from everything
    where cohort = 2022
  )
  select
    everything.urn,

    just_2021.induction_programme_choice   as "2021_induction_programme_choice",
    just_2021.in_partnership               as "2021_in_partnership",
    just_2021.lead_provider_name           as "2021_lead_provider_name",
    just_2021.delivery_partner_name        as "2021_delivery_partner_name",

    just_2022.induction_programme_choice   as "2022_induction_programme_choice",
    just_2022.in_partnership               as "2022_in_partnership",
    just_2022.lead_provider_name           as "2022_lead_provider_name",
    just_2022.delivery_partner_name        as "2022_delivery_partner_name"
  from
    everything
  left outer join
    just_2021 on everything.urn = just_2021.urn
  left outer join
    just_2022 on everything.urn = just_2022.urn
) to '/tmp/exports/schools.csv' with csv header;
