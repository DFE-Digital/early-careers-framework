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

# starting from the outside and work in, create the cpd_lead_providers

ambition                       = FactoryBot.create(:seed_cpd_lead_provider, name: "Ambition Institute")
best_practice_network          = FactoryBot.create(:seed_cpd_lead_provider, name: "Best Practice Network")
capita                         = FactoryBot.create(:seed_cpd_lead_provider, name: "Capita")
church_of_england              = FactoryBot.create(:seed_cpd_lead_provider, name: "Church of England")
education_development_trust    = FactoryBot.create(:seed_cpd_lead_provider, name: "Education Development Trust")
leadership_learning_south_east = FactoryBot.create(:seed_cpd_lead_provider, name: "Leadership Learning South East")
national_institute_of_teaching = FactoryBot.create(:seed_cpd_lead_provider, name: "National Institute of Teaching")
school_led_network             = FactoryBot.create(:seed_cpd_lead_provider, name: "School-Led Network")
teach_first                    = FactoryBot.create(:seed_cpd_lead_provider, name: "Teach First")
teacher_development_trust      = FactoryBot.create(:seed_cpd_lead_provider, name: "Teacher Development Trust")
ucl_institute_of_education     = FactoryBot.create(:seed_cpd_lead_provider, name: "UCL Institute of Education")

# now create the relevant core_induction_programmes, lead providers and set up the relationships

ambition_cip = FactoryBot.create(:seed_core_induction_programme, name: ambition.name)
edt_cip = FactoryBot.create(:seed_core_induction_programme, name: education_development_trust.name)
teach_first_cip = FactoryBot.create(:seed_core_induction_programme, name: teach_first.name)
ucl_cip = FactoryBot.create(:seed_core_induction_programme, name: ucl_institute_of_education.name)

{
  ambition_cip    => [ambition, capita],
  ucl_cip         => [ucl_institute_of_education, best_practice_network],
  edt_cip         => [education_development_trust],
  teach_first_cip => [teach_first],
}.each do |cip, cpd_lead_providers|
  cpd_lead_providers.each do |cpd_lead_provider|
    FactoryBot.create(:seed_lead_provider, cpd_lead_provider:, name: cpd_lead_provider.name).tap do |lead_provider|
      lead_provider.update!(cohorts: [cohort_2021, cohort_2022, cohort_2023])

      # FIXME: what about 2022? omitted in legacy
      FactoryBot.create(:seed_lead_provider_cip, lead_provider:, cohort: cohort_2021, core_induction_programme: cip)
    end
  end
end

# now for the NPQ lead providers, we're using some hardcoded ids here so (i assume)
# there's consistency for people testing various versions of the app across staging
# and review app environments; these uuids match prod

{
  ambition                       => "9e35e998-c63b-4136-89c4-e9e18ddde0ea",
  best_practice_network          => "57ba9e86-559f-4ff4-a6d2-4610c7259b67",
  church_of_england              => "79cb41ca-cb6d-405c-b52c-b6f7c752388d",
  education_development_trust    => "21e61f53-9b34-4384-a8f5-d8224dbf946d",
  leadership_learning_south_east => "230e67c0-071a-4a48-9673-9d043d456281",
  national_institute_of_teaching => "3ec607f2-7a3a-421f-9f1a-9aca8a634aeb",
  school_led_network             => "bc5e4e37-1d64-4149-a06b-ad10d3c55fd0",
  teach_first                    => "a02ae582-f939-462f-90bc-cebf20fa8473",
  teacher_development_trust      => "30fd937e-b93c-4f81-8fff-3c27544193f1",
  ucl_institute_of_education     => "ef687b3d-c1c0-4566-a295-16d6fa5d0fa7",
}.each do |cpd_lead_provider, id|
  FactoryBot.create(:seed_npq_lead_provider, cpd_lead_provider:, id:, name: cpd_lead_provider.name)
end
