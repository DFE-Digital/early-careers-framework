# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_nomination_email, class: "NominationEmail") do
    token { "abc123" }
    sent_to { Faker::Internet.email }
    sent_at { 1.year.ago }

    trait(:with_school) do
      association(:school, factory: %i[seed_school valid])
    end

    trait(:valid) { with_school }

    after(:build) do |nb|
      Rails.logger.debug("created nomination email for #{nb.sent_to}")
    end
  end
end
