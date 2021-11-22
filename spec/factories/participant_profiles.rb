# frozen_string_literal: true

FactoryBot.define do
  factory :participant_profile do
    teacher_profile
    profile_duplicity { :single }

    factory :ecf_participant_profile, class: ParticipantProfile::ECF do
      school_cohort
      teacher_profile { association :teacher_profile, school: school_cohort.school }
      schedule { Finance::Schedule::ECF.default || create(:ecf_schedule) }

      factory :ect_participant_profile, class: ParticipantProfile::ECT
      factory :mentor_participant_profile, class: ParticipantProfile::Mentor
    end

    trait :ecf_participant_validation_data do
      ecf_participant_validation_data { association :ecf_participant_validation_data }
    end

    trait :ecf_participant_eligibility do
      ecf_participant_eligibility { association :ecf_participant_eligibility }
    end

    factory :npq_participant_profile, class: ParticipantProfile::NPQ do
      npq_application { association :npq_application, user: teacher_profile.user, school_urn: rand(100_000..999_999) }
      schedule do |participant_profile|
        if Finance::Schedule::NPQLeadership::IDENTIFIERS.include?(participant_profile.npq_application.npq_course.identifier)
          Finance::Schedule::NPQLeadership.default || create(:npq_leadership_schedule)
        elsif Finance::Schedule::NPQSpecialist::IDENTIFIERS.include?(participant_profile.npq_application.npq_course.identifier)
          Finance::Schedule::NPQSpecialist.default || create(:npq_specialist_schedule)
        else
          NPQCourse.schedule_for(participant_profile.npq_application.npq_course)
        end
      end
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

    trait :email_sent do
      after(:create) do |profile, _evaluator|
        create :email, associated_with: profile, status: "delivered", tags: [:request_for_details]
      end
    end

    trait :email_bounced do
      after(:create) do |profile, _evaluator|
        create :email, associated_with: profile, status: "permanent-failure", tags: [:request_for_details]
      end
    end

    trait :primary_profile do
      profile_duplicity { :primary }
    end

    trait :secondary_profile do
      profile_duplicity { :secondary }
    end
  end
end
