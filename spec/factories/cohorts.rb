# frozen_string_literal: true

FactoryBot.define do
  factory :cohort do
    start_year { Faker::Date.unique.between(from: "2020-01-01", to: "2099-12-31").year }
  end
end
