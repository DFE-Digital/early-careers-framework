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

    teacher_profile

    transient do
      participant_type {}
    end

    trait :ect do
      school_cohort
      teacher_profile { association :teacher_profile, school: school_cohort.school }

      participant_type { :ect }
    end

    trait :mentor do
      school_cohort
      teacher_profile { association :teacher_profile, school: school_cohort.school }

      participant_type { :mentor }
    end

    trait :npq do
      school
      teacher_profile { association :teacher_profile, school: school }

      validation_data { association :npq_validation_data, user: teacher_profile.user}

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
