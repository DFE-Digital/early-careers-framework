# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_participant_profile, class: "ParticipantProfile") do
    schedule { Finance::Schedule.first }

    trait :with_school do
      user { build(:seed_school) }
    end

    trait :with_teacher_profile do
      teacher_profile { build(:seed_teacher_profile) }
    end

    trait :with_participant_identity do
      participant_identity { build(:seed_participant_identity) }
    end
  end
end
