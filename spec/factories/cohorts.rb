# frozen_string_literal: true

FactoryBot.define do
  factory :cohort do
    start_year { 2020 + Faker::Number.unique.between(from: 1, to: 79) }
  end
end
