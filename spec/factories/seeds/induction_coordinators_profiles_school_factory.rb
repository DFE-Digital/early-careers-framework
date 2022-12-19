# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_induction_coordinator_profiles_school, class: "InductionCoordinatorProfilesSchool") do
    trait(:with_induction_coordinator_profile) do
      association(:induction_coordinator_profile, factory: %i[seed_induction_coordinator_profile valid])
    end
    trait(:with_school) { association(:school, factory: :seed_school) }

    trait(:valid) do
      with_induction_coordinator_profile
      with_school
    end

    after(:build) do |icps|
      if icps.school.present? && icps.induction_coordinator_profile.present?
        Rails.logger.debug("built incomplete induction coordinator profile #{icps.induction_coordinator_profile.id} at #{icps.school.name}")
      else
        Rails.logger.debug("built incomplete induction coordinator profile school")
      end
    end
  end
end
