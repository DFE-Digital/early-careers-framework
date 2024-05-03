# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_cohort, class: "Cohort") do
    sequence(:start_year) { Faker::Number.unique.between(from: 2050, to: 3025) }

    registration_start_date { Date.new(start_year, 5, 1) }
    academic_year_start_date { Date.new(start_year, 9, 1) }
    automatic_assignment_period_end_date { Date.new(start_year + 1, 3, 31) }

    initialize_with do
      Cohort.find_by(start_year:) || new(**attributes)
    end

    trait(:valid) {}

    after(:build) { |cohort| Rails.logger.debug("seeded cohort #{cohort.start_year}") }
  end
end
