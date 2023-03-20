# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_school_mentor, class: "SchoolMentor") do
    trait(:with_school) do
      association(:school, factory: :seed_school)
    end

    trait(:with_participant_profile) do
      association(:participant_profile, factory: %i[seed_mentor_participant_profile valid])
    end

    trait(:with_preferred_identity) do
      association(:preferred_identity, factory: %i[seed_participant_identity valid])
    end

    # this trait ensures the participant profile and preferred identity are linked to
    # each other rather than generated in isolation
    trait(:with_participant_profile_and_identity) do
      association(:participant_profile, factory: %i[seed_mentor_participant_profile valid])

      preferred_identity { |sm| sm.participant_profile.participant_identity }
    end

    trait(:valid) do
      with_school
      with_participant_profile_and_identity
    end

    after(:build) do |sm|
      if sm.school.present? && sm.participant_profile.present?
        Rails.logger.debug("seeded school_mentor for #{sm.participant_profile.full_name} at #{sm.school.name}")
      else
        Rails.logger.debug("seeded incomplete school mentor record")
      end
    end
  end
end
