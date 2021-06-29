# frozen_string_literal: true

FactoryBot.define do
  factory :participant_profile do
    initialize_with { [ParticipantProfile::ECT, ParticipantProfile::Mentor].sample.new(attributes) }

    user
    school
    cohort { create(:cohort, :current) }

    trait :ect do
      initialize_with { ParticipantProfile::ECT.new(attributes) }
    end

    trait :mentor do
      initialize_with { ParticipantProfile::Mentor.new(attributes) }
    end

    trait :sparsity_uplift do
      sparsity_uplift { true }
    end

    trait :pupil_premium_uplift do
      pupil_premium_uplift { true }
    end

    trait :uplift_flags do
      sparsity_uplift
      pupil_premium_uplift
    end
  end

  # TODO: Legacy factory, to be replaced with [:participant_profile, :ect]
  factory :early_career_teacher_profile, class: ParticipantProfile::ECT do
    user
    school
    cohort { create(:cohort, :current) }
    mentor_profile
  end

  # TODO: Legacy factory, to be replaced with [:participant_profile, :mentor]
  factory :mentor_profile, class: ParticipantProfile::Mentor do
    user
    school
    cohort { Cohort.current || create(:cohort, :current) }
  end
end
