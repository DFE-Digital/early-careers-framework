# frozen_string_literal: true

# create some local authorities
local_authorities = FactoryBot.create_list(:local_authority, 10)

cohorts = Cohort.where(start_year: [2021, 2022])
lead_providers = LeadProvider.all

# create some generic schools with:
# * [x] a local authority
# * [x] an induction tutor
# * [x] some school cohorts
# * [x] partnerships
# * [x] some ects
# * [ ] some ects with eligibility
# * [x] some mentors
# * [ ] some declarations
local_authorities.each do |local_authority|
  FactoryBot.create(:seed_school).tap do |school|
    FactoryBot.create(:seed_school_local_authority, school:, local_authority:)
    FactoryBot.create(:seed_induction_coordinator_profile, :with_user).tap do |induction_coordinator_profile|
      FactoryBot.create(:seed_induction_coordinator_profiles_school, induction_coordinator_profile:, school:)

      cohorts.sample(Random.rand(1..cohorts.length)).each do |cohort|
        FactoryBot.create(:seed_school_cohort, school:, cohort:)
      end

      lead_providers.sample do |lead_provider|
        # TODO: partnerhips also have a cohort, do we set that here? Seems to work ok without
        FactoryBot.create(:seed_partnership, :with_delivery_partner, school:, lead_provider:)

        Random.rand(1..4).times do
          NewSeeds::Scenarios::Participants::Mentors::MentoringMultipleEctsWithSameProvider
            .new(
              school:,
              lead_provider:,
              number: Random.rand(1..4), # number of mentees
            )
            .build
        end
      end
    end
  end
end
