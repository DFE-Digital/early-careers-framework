# frozen_string_literal: true

FactoryBot.define do
  factory :participant_profile do
    transient do
      profile_traits { [] }
    end

    factory :ecf_participant_profile, class: "ParticipantProfile::ECF" do
      profile_duplicity { :single }
      school_cohort { association :school_cohort }
      teacher_profile { association :teacher_profile, school: school_cohort.school }
      schedule { Finance::Schedule::ECF.default || create(:ecf_schedule) }
      after :build do |participant_profile|
        participant_profile.participant_identity = Identity::Create.call(user: participant_profile.user)
      end

      factory :ect_participant_profile, class: "ParticipantProfile::ECT"
      factory :mentor_participant_profile, class: "ParticipantProfile::Mentor"
    end

    trait :ecf_participant_validation_data do
      ecf_participant_validation_data { association :ecf_participant_validation_data }
    end

    trait :ecf_participant_eligibility do
      ecf_participant_eligibility { association :ecf_participant_eligibility }
    end

    factory :npq_participant_profile, class: "ParticipantProfile::NPQ" do
      transient do
        user              { create(:user) }
        npq_lead_provider { create(:cpd_lead_provider, :with_npq_lead_provider).npq_lead_provider }
        trn               { user.teacher_profile&.trn || sprintf("%07i", Random.random_number(9_999_999)) }
      end
      npq_application { create(:npq_application, *profile_traits, :accepted, user:, npq_lead_provider:) }

      initialize_with do
        npq_application.profile
      end

      trait :with_participant_profile_state do
        after(:build) do |participant_profile|
          participant_profile.participant_profile_states << build(:participant_profile_state, state: participant_profile.training_status)
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

      after(:create) do |profile, _evaluator|
        if profile.ecf_participant_eligibility.present?
          profile.ecf_participant_eligibility.determine_status
          profile.ecf_participant_eligibility.save!
        end
      end
    end
  end
end
