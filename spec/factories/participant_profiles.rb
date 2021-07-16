# frozen_string_literal: true

FactoryBot.define do
  factory :participant_profile do
    initialize_with do
      if participant_type.nil?
        build :participant_profile, %i[ect mentor npq].sample, attributes
      else
        klass = case participant_type
                when :ect then ParticipantProfile::ECT
                when :mentor then ParticipantProfile::Mentor
                when :npq then ParticipantProfile::NPQ
                else
                  raise "Unknown participant type: #{participant_type}"
                end
        klass.new(attributes)
      end
    end

    user

    transient do
      participant_type {}
    end

    school_cohort

    trait :ect do
      participant_type { :ect }
    end

    trait :mentor do
      participant_type { :mentor }
    end

    trait :npq do
      participant_type { :npq }
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
