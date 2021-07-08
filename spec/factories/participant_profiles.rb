# frozen_string_literal: true

FactoryBot.define do
  factory :participant_profile do
    user

    type do
      case participant_type
      when :ect then "ParticipantProfile::ECT"
      when :mentor then "ParticipantProfile::Mentor"
      else
        raise "Unknown participant type: #{participant_type}"
      end
    end

    transient do
      participant_type { %i[ect mentor].sample }
    end

    trait :ect do
      cohort
      school

      participant_type { :ect }
    end

    trait :mentor do
      cohort
      school

      participant_type { :mentor }
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
end
