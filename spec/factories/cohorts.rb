# frozen_string_literal: true

FactoryBot.define do
  sequence :base_year do |n|
    2020 + n
  end

  factory :cohort do
    start_year { Faker::Number.unique.between(from: 2022, to: 2100) }
    registration_start_date { Date.new(start_year.to_i, 5, 10) }
    academic_year_start_date { Date.new(start_year.to_i, 9, 1) }

    trait :current do
      start_year { 2021 }
    end

    trait :next do
      start_year { 2022 }
      academic_year_start_date { 1.day.from_now.to_date }
    end

    trait :consecutive_years do
      start_year { generate(:base_year) }
    end
  end
end
