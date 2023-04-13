# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_finance_milestone, class: "Finance::Milestone") do
    name { Faker::Lorem.sentence }

    milestone_date { 6.months.ago.to_date }
    payment_date { 5.months.ago.to_date }

    trait(:with_schedule) do
      association(:schedule, factory: %i[seed_finance_schedule valid])
    end

    trait(:valid) { with_schedule }

    after(:build) do |m|
      Rails.logger.debug("created milestone #{m.name}")
    end
  end
end
