# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_abstract_participant_profile_state, class: "ParticipantProfileState") do
    factory(:seed_npq_participant_profile_state) do
      trait(:with_participant_profile) do
        association(:participant_profile, factory: %i[seed_npq_participant_profile valid])
      end
    end

    factory(:seed_ect_participant_profile_state) do
      trait(:with_participant_profile) do
        association(:participant_profile, factory: %i[seed_ect_participant_profile valid])
      end
    end

    state { "active" }

    trait(:valid) do
      with_participant_profile
    end

    after(:build) do
      Rails.logger.debug("seeded participant profile state")
    end
  end
end
