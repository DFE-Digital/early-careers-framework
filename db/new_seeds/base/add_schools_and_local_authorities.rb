# frozen_string_literal: true

# create some local authorities
local_authorities = FactoryBot.create_list(:local_authority, 10)

# create some generic schools with:
# * [x] a local authority
# * [x] an induction tutor
# * [ ] some school cohorts
# * [ ] partnership
# * [ ] some ects
# * [ ] some ects with eligibility
# * [ ] some mentors
# * [ ] some declarations
local_authorities.each do |local_authority|
  FactoryBot.create(:seed_school).tap do |school|
    FactoryBot.create(:seed_school_local_authority, school:, local_authority:)
    FactoryBot.create(:seed_induction_coordinator_profile, :with_user).tap do |induction_coordinator_profile|
      FactoryBot.create(:seed_induction_coordinator_profiles_school, induction_coordinator_profile:, school:)
    end
  end
end
