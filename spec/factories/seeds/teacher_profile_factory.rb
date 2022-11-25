# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_teacher_profile, class: "TeacherProfile") do
    trn { Faker::Number.unique.rand_in_range(10_000, 100_000).to_s }

    trait :with_school do
      school { build(:seed_school) }
    end

    trait :with_participant_identity do
      participant_identity { build(:seed_participant_identity) }
    end

    trait :with_user do
      user { build(:seed_user) }
    end
  end
end
