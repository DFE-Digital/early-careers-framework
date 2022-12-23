# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_npq_participant_profile, class: "ParticipantProfile::NPQ") do
    schedule { Finance::Schedule.first }

    trait :with_schedule do
      association(:schedule, factory: %i[seed_finance_schedule valid])
    end

    trait :with_teacher_profile do
      association(:teacher_profile, factory: %i[seed_teacher_profile valid])
    end

    trait :with_participant_identity do
      association(:participant_identity, factory: %i[seed_participant_identity valid])
    end

    trait(:valid) do
      with_schedule
      with_teacher_profile
      with_participant_identity
    end

    after(:build) do |npq|
      if npq.user.present?
        Rails.logger.debug("created NPQ profile for #{npq.user.full_name}")
      else
        Rails.logger.debug("created incomplete NPQ profile")
      end
    end
  end
end
