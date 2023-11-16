# frozen_string_literal: true

school = FactoryBot.create(:school, name: "Include this school", urn: 123_456)
local_authority = FactoryBot.create(:local_authority)
SchoolLocalAuthority.create!(school:, local_authority:, start_year: 2021)
coordinator = FactoryBot.create(:user, :induction_coordinator, full_name: "Sarah Smith", email: "sarah.smith@example.com")
coordinator.induction_coordinator_profile.schools.first.destroy!
coordinator.induction_coordinator_profile.schools = [school]

school_with_cohorts = FactoryBot.create(:school, name: "Cohort School", urn: 900_123)
cohort_previous = Cohort.previous || FactoryBot.create(:cohort, :previous)
cohort_current = Cohort.current || FactoryBot.create(:cohort, :current)

cip_1 = FactoryBot.create(:core_induction_programme, name: "CIP Programme 1")
cip_2 = FactoryBot.create(:core_induction_programme, name: "CIP Programme 2")
FactoryBot.create(:school_cohort, :cip, :with_induction_programme, cohort: cohort_previous, school: school_with_cohorts, core_induction_programme: cip_1)
FactoryBot.create(:school_cohort, :cip, :with_induction_programme, cohort: cohort_current, school: school_with_cohorts, core_induction_programme: cip_2)

FactoryBot.create(:seed_partnership, :with_lead_provider, :valid, cohort: cohort_previous, school:)
FactoryBot.create(:seed_partnership, :with_lead_provider, :valid, cohort: cohort_current, school:)
FactoryBot.create(:seed_partnership, :with_lead_provider, :valid, cohort: cohort_previous, school: school_with_cohorts)
FactoryBot.create(:seed_partnership, :with_lead_provider, :valid, cohort: cohort_current, school: school_with_cohorts)

Faker::UniqueGenerator.clear
Faker::Config.random = Random.new(42)
FactoryBot.create_list(:school, 7)
Faker::Config.random = nil
