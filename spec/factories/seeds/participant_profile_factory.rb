# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_participant_profile, class: "ParticipantProfile") do
    factory(:seed_ecf_participant_profile, class: "ParticipantProfile::ECF") do
      type { "ParticipantProfile::ECF" }
    end

    schedule { Finance::Schedule.first }

    trait :with_user do
      user { build(:seed_user) }
    end

    trait :with_teacher_profile do
      teacher_profile { build(:seed_teacher_profile) }
    end

    trait :with_participant_identity do
      participant_identity { build(:seed_participant_identity) }
    end

    after(:build) { |pp| Rails.logger.debug("seeded participant_profile for user #{pp.user.full_name}") }
  end
end
