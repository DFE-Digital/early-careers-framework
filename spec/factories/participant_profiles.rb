# frozen_string_literal: true

FactoryBot.define do
  factory :participant_profile do
    transient do
      cohort         { Cohort.current || create(:cohort, :current) }
      profile_traits { [] }
    end

    trait(:ecf) do
      profile_duplicity { :single }
      school_cohort { association :school_cohort, cohort: }
      teacher_profile { association :teacher_profile, school: school_cohort.school }
      schedule { Finance::Schedule::ECF.default_for(cohort: school_cohort.cohort) || create(:ecf_schedule, cohort: school_cohort.cohort) }

      after :build do |participant_profile|
        participant_profile.participant_identity = Identity::Create.call(user: participant_profile.user)
      end
    end

    factory(:ect_participant_profile, class: "ParticipantProfile::ECT") { ecf }
    factory(:mentor_participant_profile, class: "ParticipantProfile::Mentor") { ecf }

    trait :ecf_participant_validation_data do
      ecf_participant_validation_data { association :ecf_participant_validation_data }
    end

    trait :ecf_participant_eligibility do
      ecf_participant_eligibility { association :ecf_participant_eligibility }
    end

    factory :npq_participant_profile, class: "ParticipantProfile::NPQ" do
      transient do
        npq_course        { create(:npq_course) }
        user              { create(:user) }
        npq_lead_provider { create(:cpd_lead_provider, :with_npq_lead_provider).npq_lead_provider }
        trn               { user.teacher_profile&.trn || sprintf("%07i", Random.random_number(9_999_999)) }
      end
      npq_application { create(:npq_application, *profile_traits, :accepted, user:, npq_lead_provider:, npq_course:, cohort:) }

      trait :eligible_for_funding do
        profile_traits { [:eligible_for_funding] }
      end

      trait :withdrawn do
        transient do
          reason { "other" }
        end

        after(:create) do |participant_profile, evaluator|
          WithdrawParticipant.new(
            participant_id: participant_profile.teacher_profile.user_id,
            cpd_lead_provider: participant_profile.npq_application.npq_lead_provider.cpd_lead_provider,
            reason: evaluator.reason,
            course_identifier: participant_profile.npq_application.npq_course.identifier,
          ).call
        end
      end

      trait :deferred do
        after(:create) do |participant_profile|
          DeferParticipant.new(
            participant_id: participant_profile.teacher_profile.user_id,
            course_identifier: participant_profile.npq_application.npq_course.identifier,
            cpd_lead_provider: participant_profile.npq_application.npq_lead_provider.cpd_lead_provider,
            reason: "bereavement",
          ).call
        end
      end

      initialize_with do
        npq_application.profile
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
        profile.teacher_profile.update!(trn: nil)
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
