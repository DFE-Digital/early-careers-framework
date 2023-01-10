# frozen_string_literal: true

FactoryBot.define do
  factory :ect, class: "EarlyCareerTeachers::Create" do
    transient do
      cohort        { Cohort.current || create(:cohort, :current) }
      lead_provider { create(:cpd_lead_provider, :with_lead_provider).lead_provider }
      uplifts       { [] }
    end

    user              { create(:user) }
    mentor_profile_id {}
    sit_validation    { false }
    school_cohort do
      create(:school_cohort, :fip, :with_induction_programme, *uplifts, lead_provider:, cohort:)
    end

    trait :sparsity_uplift do
      uplifts { %i[sparsity_uplift] }
    end

    trait :pupil_premium_uplift do
      uplifts { %i[pupil_premium_uplift] }
    end

    trait :pupil_premium_and_sparsity_uplift do
      uplifts { %i[pupil_premium_and_sparsity_uplift] }
    end

    initialize_with do
      EarlyCareerTeachers::Create.call(
        email: user.email,
        full_name: user.full_name,
        mentor_profile_id:,
        school_cohort:,
        sit_validation:,
      )
    end

    trait :eligible_for_funding do
      transient do
        trn                    { rand(100_000..999_999).to_s }
        date_of_birth          { Date.new(1993, 11, 16) }
        previous_induction     { false }
        previous_participation { false }
        deduplicate            { true }
      end

      after :create do |ect, evaluator|
        StoreValidationResult.new(
          participant_profile: ect,
          validation_data: {
            trn: evaluator.trn,
            full_name: ect.user.full_name,
            dob: evaluator.date_of_birth,
            nino: "QQ123456A",
          },
          dqt_response: {
            trn: evaluator.trn,
            qts: true,
            active_alert: false,
            previous_participation: evaluator.previous_participation,
            previous_induction: evaluator.previous_induction,
          },
          deduplicate: evaluator.deduplicate,
        ).call
      end
    end

    trait :ineligible do
      transient do
        trn                    { rand(100_000..999_999).to_s }
        previous_induction     { true }
        previous_participation { false }
        active_alert           { false }
        qts                    { true }
      end

      after :create do |ect, evaluator|
        StoreValidationResult.call(
          participant_profile: ect,
          validation_data: {
            trn: evaluator.trn,
          },
          dqt_response: {
            trn: evaluator.trn,
            qts: evaluator.qts,
            active_alert: evaluator.active_alert,
            previous_participation: evaluator.previous_participation,
            previous_induction: evaluator.previous_induction,
          },
        )
      end
    end

    trait :deferred do
      after(:create) do |participant_profile|
        DeferParticipant.new(
          participant_id: participant_profile.teacher_profile.user_id,
          course_identifier: "ecf-induction",
          cpd_lead_provider: participant_profile.current_induction_records.first.cpd_lead_provider,
          reason: "bereavement",
        ).call
      end
    end

    trait :withdrawn_record do
      after(:create, &:withdrawn_record!)
    end

    trait :withdrawn do
      transient do
        reason { "other" }
      end

      after(:create) do |participant_profile, evaluator|
        WithdrawParticipant.new(
          participant_id: participant_profile.participant_identity.external_identifier,
          cpd_lead_provider: participant_profile.induction_records.latest.cpd_lead_provider,
          reason: evaluator.reason,
          course_identifier: "ecf-induction",
        ).call
      end
    end
  end
end
