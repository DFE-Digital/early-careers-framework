# frozen_string_literal: true

# create the following set of records in a way that matches production
#
#                  ┌──────────────────────┐
#                  │  cpd_lead_providers  │
#                  └──────────┬─┬─────────┘
#                             │ │
#                             │ │
#                    has many │ │ has many
#                             │ │
#      ┌──────────────────┐   │ │  ┌──────────────────────┐
#      │  lead_providers  ◄───┘ └──►  npq_lead_providers  │
#      └─────────┬────────┘        └──────────────────────┘
#                │
#                │
#                │
#     ┌──────────▼───────────┐
#     │  lead_provider_cips  │ has many (through)
#     └──────────▲───────────┘
#                │
#                │
#                │
#  ┌─────────────┴───────────────┐
#  │  core_induction_programmes  │
#  └─────────────────────────────┘

# we're going to need to set cohorts later so find them before we start

cohort_2021 = Cohort.find_by(start_year: 2021)
cohort_2022 = Cohort.find_by(start_year: 2022)
cohort_2023 = Cohort.find_by(start_year: 2023)
cohort_2024 = Cohort.find_by(start_year: 2024)
cohort_2025 = Cohort.find_by(start_year: 2025)

# starting from the outside and work in, create the cpd_lead_providers

ambition                       = FactoryBot.create(:seed_cpd_lead_provider, name: "Ambition Institute")
best_practice_network          = FactoryBot.create(:seed_cpd_lead_provider, name: "Best Practice Network")
capita                         = FactoryBot.create(:seed_cpd_lead_provider, name: "Capita")
education_development_trust    = FactoryBot.create(:seed_cpd_lead_provider, name: "Education Development Trust")
niot                           = FactoryBot.create(:seed_cpd_lead_provider, name: "National Institute of Teaching")
teach_first                    = FactoryBot.create(:seed_cpd_lead_provider, name: "Teach First")
ucl_institute_of_education     = FactoryBot.create(:seed_cpd_lead_provider, name: "UCL Institute of Education")

# now create the relevant core_induction_programmes, lead providers and set up the relationships

ambition_cip = FactoryBot.create(:seed_core_induction_programme, name: ambition.name)
edt_cip = FactoryBot.create(:seed_core_induction_programme, name: education_development_trust.name)
teach_first_cip = FactoryBot.create(:seed_core_induction_programme, name: teach_first.name)
ucl_cip = FactoryBot.create(:seed_core_induction_programme, name: ucl_institute_of_education.name)
niot_cip = FactoryBot.create(:seed_core_induction_programme, name: niot.name)

{
  ambition_cip    => [ambition, capita],
  ucl_cip         => [ucl_institute_of_education, best_practice_network],
  edt_cip         => [education_development_trust],
  teach_first_cip => [teach_first],
  niot_cip        => [niot],
}.each do |cip, cpd_lead_providers|
  cpd_lead_providers.each do |cpd_lead_provider|
    FactoryBot.create(:seed_lead_provider, cpd_lead_provider:, name: cpd_lead_provider.name).tap do |lead_provider|
      lead_provider.update!(cohorts: [cohort_2021, cohort_2022, cohort_2023, cohort_2024, cohort_2025])

      # FIXME: what about 2022? omitted in legacy
      FactoryBot.create(:seed_lead_provider_cip, lead_provider:, cohort: cohort_2021, core_induction_programme: cip)
    end
  end
end
