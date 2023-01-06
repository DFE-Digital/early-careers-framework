# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_ecf_participant_eligibilty, class: "ECFParticipantEligibility") do
    trait(:with_participant_profile) do
      association(:participant_profile, factory: %i[seed_ect_participant_profile valid])
    end

    qts { true }
    active_flags { false }
    previous_participation { false }
    previous_induction { false }
    no_induction { false }

    status { :eligible }
    reason { :none }

    trait(:ineligible) { status { :ineligible } }

    trait(:manual_check) { status { :manual_check } }

    trait(:no_induction) do
      no_induction { true }
      manual_check
      reason { :no_induction }
    end

    trait(:no_qts) do
      qts { false }
      manual_check
      reason { :no_qts }
    end

    trait(:active_flags) do
      active_flags { true }
      manual_check
      reason { :active_flags }
    end

    trait(:different_trn) do
      different_trn { true }
      manual_check
      reason { :different_trn }
    end

    trait(:previous_induction) do
      previous_induction { true }
      ineligible
      reason { :previous_induction }
    end

    trait(:previous_participation) do
      previous_participation { true }
      ineligible
      reason { :previous_participation }
    end

    trait(:secondary_profile) do
      ineligible
      reason { :duplicate_profile }
    end

    trait(:exempt_from_induction) do
      exempt_from_induction { true }
      ineligible
      reason { :exempt_from_induction }
    end

    trait(:valid) { with_participant_profile }

    after(:build) do |pe|
      if pe.participant_profile.present?
        Rails.logger.debug("seeded participant eligibility of #{pe.status} for #{pe.participant_profile.full_name}")
      else
        Rails.logger.debug("seeded incomplete participant eligibility")
      end
    end
  end
end
