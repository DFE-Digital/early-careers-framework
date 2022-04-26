# frozen_string_literal: true

FactoryBot.define do
  factory :cohort do
    start_year { Faker::Number.unique.between(from: 2022, to: 2100) }
    registration_start_date { Date.new(start_year.to_i, 5, 10) }
    academic_year_start_date { Date.new(start_year.to_i, 9, 1) }

    trait :current do
      start_year { 2021 }
    end

    trait :next do
      start_year { 2022 }
    end
  end
end
