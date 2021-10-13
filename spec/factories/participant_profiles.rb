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

    schedule
    teacher_profile

    transient do
      participant_type {}
    end

    trait :ecf do
      if [true, false].sample
        ect
      else
        mentor
      end
    end

    trait :ect do
      school_cohort
      teacher_profile { association :teacher_profile, school: school_cohort.school }
      schedule

      participant_type { :ect }
    end

    trait :mentor do
      school_cohort
      teacher_profile { association :teacher_profile, school: school_cohort.school }
      schedule

      participant_type { :mentor }
    end

    trait :ecf_participant_validation_data do
      ecf_participant_validation_data { association :ecf_participant_validation_data }
    end

    trait :ecf_participant_eligibility do
      ecf_participant_eligibility { association :ecf_participant_eligibility }
    end

    trait :npq do
      teacher_profile { association :teacher_profile }
      schedule

      npq_application { association :npq_application, user: teacher_profile.user, school_urn: rand(100_000..999_999) }

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

    trait :withdrawn_record do
      status { :withdrawn }
    end
  end
end
