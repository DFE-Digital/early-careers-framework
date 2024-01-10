# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_ecf_ineligible_participant, class: "ECFIneligibleParticipant") do
    trn { "00#{Faker::Number.unique.rand_in_range(10_000, 99_999)}" }
    reason { "previous_participation" }

    trait(:valid) {}

    after(:build) do |_eip|
      Rails.logger.debug("seeded ineligible participant item")
    end
  end
end
