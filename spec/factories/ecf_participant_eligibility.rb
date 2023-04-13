# frozen_string_literal: true

FactoryBot.define do
  factory :ecf_participant_eligibility, class: ECFParticipantEligibility do
    association :participant_profile, factory: :ect_participant_profile

    qts { true }
    active_flags { false }
    previous_participation { false }
    previous_induction { false }
    no_induction { false }

    status { :eligible }
    reason { :none }

    trait :ineligible do
      status { :ineligible }
    end

    trait :manual_check do
      status { :manual_check }
    end

    trait :no_induction_state do
      no_induction { true }
      manual_check
      reason { :no_induction }
    end

    trait :no_qts_state do
      qts { false }
      manual_check
      reason { :no_qts }
    end

    trait :active_flags_state do
      active_flags { true }
      manual_check
      reason { :active_flags }
    end

    trait :different_trn_state do
      different_trn { true }
      manual_check
      reason { :different_trn }
    end

    trait :previous_induction_state do
      previous_induction { true }
      ineligible
      reason { :previous_induction }
    end

    trait :previous_participation_state do
      previous_participation { true }
      ineligible
      reason { :previous_participation }
    end

    trait :secondary_profile_state do
      ineligible
      reason { :duplicate_profile }
    end

    trait :exempt_from_induction_state do
      exempt_from_induction { true }
      ineligible
      reason { :exempt_from_induction }
    end
  end
end
