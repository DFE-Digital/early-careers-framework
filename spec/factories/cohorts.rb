# frozen_string_literal: true

FactoryBot.define do
  factory :cohort do
    start_year { Faker::Number.unique.between(from: 2022, to: 2100) }

    trait :current do
      start_year { 2021 }
    end

    trait :next do
      start_year { 2022 }
    end
  end
end
