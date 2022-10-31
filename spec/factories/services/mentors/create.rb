# frozen_string_literal: true

FactoryBot.define do
  factory :mentor, class: "Mentors::Create" do
    transient do
      lead_provider { create(:cpd_lead_provider, :with_lead_provider).lead_provider }
      uplifts { [] }
      trn { user.teacher_profile&.trn || sprintf("%07i", Random.random_number(9_999_999)) }
    end

    user            { create(:user) }
    sit_validation  { false }
    school_cohort   { create(:school_cohort, :fip, :with_induction_programme, *uplifts, lead_provider:) }
    full_name       { user.full_name }
    email           { user.email }

    trait :sparsity_uplift do
      uplifts { %i[sparsity_uplift] }
    end

    trait :pupil_premium_uplift do
      uplifts { %i[pupil_premium_uplift] }
    end

    trait :with_uplifts do
      uplifts { %i[pupil_premium_uplift sparsity_uplift] }
    end

    trait :eligible_for_funding do
      transient do
        trn { sprintf("%07i", Random.random_number(9_999_999)) }
      end

      after :create do |mentor, evaluator|
        StoreValidationResult.new(
          participant_profile: mentor,
          validation_data: {
            trn: evaluator.trn,
            full_name: mentor.user.full_name,
            date_of_birth: Date.new(1993, 11, 16),
            nino: "QQ123456A",
          },
          dqt_response: {
            trn: evaluator.trn,
            qts: true,
            active_alert: false,
            previous_participation: false,
            previous_induction: false,
          },
          deduplicate: true,
        ).call
        mentor.reload
      end
    end

    trait :deferred do
      after(:create) do |participant_profile|
        DeferParticipant.new(
          participant_id: participant_profile.teacher_profile.user_id,
          course_identifier: "ecf-mentor",
          cpd_lead_provider: participant_profile.current_induction_records.first.cpd_lead_provider,
          reason: "bereavement",
        ).call
      end
    end

    trait :withdrawn do
      transient do
        reason { "other" }
      end

      after(:create) do |participant_profile, evaluator|
        WithdrawParticipant.new(
          participant_id: participant_profile.teacher_profile.user_id,
          cpd_lead_provider: participant_profile.current_induction_records.first.cpd_lead_provider,
          reason: evaluator.reason,
          course_identifier: "ecf-mentor",
        ).call
        participant_profile.reload
      end
    end

    trait :email_sent do
      transient do
        request_for_details_sent_at { 5.days.ago }
      end

      after(:create) do |profile, evaluator|
        profile.update!(request_for_details_sent_at: evaluator.request_for_details_sent_at)
        create :email, associated_with: profile, status: "delivered", tags: [:request_for_details]
      end
    end

    trait :withdrawn_record do
      after(:create) do |participant_profile|
        participant_profile.withdrawn_record!
        participant_profile.reload
      end
    end

    # trait :ineligible do
    #   after :create do |mentor, evaluator|
    #     mentor.secondary_profile!
    #     StoreParticipantEligibility.call(
    #       participant_profile: mentor,
    #       eligibility_options: {
    #         status: :ineligible,
    #       },
    #     )
    #     mentor.reload
    #   end
    # end

    trait :deferred do
      transient do
        reason { "bereavement" }
      end
      after(:create) do |participant_profile, evaluator|
        DeferParticipant.new(
          participant_id: participant_profile.user_id,
          course_identifier: "ecf-mentor",
          cpd_lead_provider: participant_profile.current_induction_record.cpd_lead_provider,
          reason: evaluator.reason,
        ).call
        participant_profile.reload
      end
    end

    initialize_with do
      Mentors::Create.call(**attributes)
    end
  end
end
