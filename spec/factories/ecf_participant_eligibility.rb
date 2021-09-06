# frozen_string_literal: true

FactoryBot.define do
  factory :ecf_participant_eligibility, class: ECFParticipantEligibility do
    association :participant_profile, :ecf
  end
end
