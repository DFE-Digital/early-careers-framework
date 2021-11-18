# frozen_string_literal: true

FactoryBot.define do
  factory :ecf_participant_eligibility, class: ECFParticipantEligibility do
    participant_profile { create :ecf_participant_profile }

    qts { true }
    active_flags { false }
    previous_participation { false }
    previous_induction { false }

    transient do
      reason {}
    end

    after(:create) do |record, evaluator|
      record.update!(reason: evaluator.reason) if evaluator.reason
    end

    trait :eligible do
      after(:create) do |record, _evaluator|
        record.eligible_status!
      end
    end

    trait :ineligible do
      after(:create) do |record, _evaluator|
        record.ineligible_status!
      end
    end

    trait :matched do
      after(:create) do |record, _evaluator|
        record.matched_status!
      end
    end

    trait :manual_check do
      after(:create) do |record, _evaluator|
        record.manual_check_status!
      end
    end
  end
end
