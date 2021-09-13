# frozen_string_literal: true

FactoryBot.define do
  factory :ineligible_participant, class: ECFIneligibleParticipant do
    trn { Faker::Number.unique.between(from: 1000000, to: 9999999) }
    reason { %w[previous_participation previous_induction].sample }
  end
end
