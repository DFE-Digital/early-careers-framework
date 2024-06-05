# frozen_string_literal: true

FactoryBot.define do
  sequence :base_year do |n|
    2020 + n
  end

  factory :cohort do
    start_year { Faker::Number.unique.between(from: 2022, to: 2100) }
    registration_start_date { Date.new(start_year.to_i, 6, 5) }
    academic_year_start_date { Date.new(start_year.to_i, 9, 1) }
    automatic_assignment_period_end_date { Date.new(start_year.to_i + 1, 3, 31) }

    initialize_with do
      Cohort.find_by(start_year:) || new(**attributes)
    end

    trait :previous do
      start_year { Date.current.year - (Date.current.month < 9 ? 2 : 1) }
    end

    trait :current do
      start_year { Date.current.year - (Date.current.month < 9 ? 1 : 0) }
    end

    trait :next do
      start_year { Date.current.year + (Date.current.month < 9 ? 0 : 1) }
    end

    trait :payments_frozen do
      payments_frozen_at { Time.zone.now }
    end

    trait :consecutive_years do
      start_year { generate(:base_year) }
    end

    initialize_with do
      Cohort.find_by(start_year:) || new(**attributes)
    end
  end
end
