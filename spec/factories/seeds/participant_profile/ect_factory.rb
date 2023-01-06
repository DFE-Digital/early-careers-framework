# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_ect_participant_profile, class: "ParticipantProfile::ECT") do
    type { "ParticipantProfile::ECT" }

    schedule { Finance::Schedule::ECF.default }

    trait :with_teacher_profile do
      association(:teacher_profile, factory: %i[seed_teacher_profile valid])
    end

    trait :with_participant_identity do
      association(:participant_identity, factory: %i[seed_participant_identity valid])
    end

    trait :with_schedule do
      association(:schedule, factory: %i[seed_finance_schedule valid])
    end

    trait :with_school_cohort do
      association(:school_cohort, factory: %i[seed_school_cohort valid])
    end

    trait(:valid) do
      with_teacher_profile
      with_participant_identity
      with_schedule
      with_school_cohort
    end

    after(:build) do |pp|
      if pp.user.present?
        Rails.logger.debug("seeded ect participant_profile for user #{pp.user.full_name}")
      else
        Rails.logger.debug("seeded ect participant_profile with no user")
      end
    end
  end
end
