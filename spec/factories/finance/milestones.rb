# frozen_string_literal: true

FactoryBot.define do
  factory :milestone, class: "Finance::Milestone" do
    name { "Test milestone" }

    start_date { Time.zone.now - 1.month }
    milestone_date { Time.zone.now + 1.month }
    payment_date { Time.zone.now + 2.months }
  end
end
