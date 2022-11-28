# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_teacher_profile, class: "TeacherProfile") do
    trn { Faker::Number.unique.rand_in_range(10_000, 100_000).to_s }

    trait :with_school do
      school { build(:seed_school) }
    end

    trait :with_mentor_profile do
      mentor_profile { build(:seed_mentor_profile) }
    end

    trait :with_user do
      user { build(:seed_user) }
    end

    after(:build) do |tp|
      Rails.logger.debug("seeded teacher profile for user #{tp.user.full_name} with TRN #{tp.trn}")
    end
  end
end
