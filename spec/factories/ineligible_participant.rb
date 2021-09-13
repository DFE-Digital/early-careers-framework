# frozen_string_literal: true

FactoryBot.define do
  factory :ineligible_participant, class: ECFIneligibleParticipant do
    trn { Faker::Number.unique.between(from: 1_000_000, to: 9_999_999) }
    reason { %w[previous_participation previous_induction].sample }
  end
end
