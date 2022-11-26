# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_cohort, class: "Cohort") do
    sequence(:start_year) { Faker::Number.unique.between(from: 2025, to: 3025) }

    registration_start_date { Date.new(start_year, 5) }
    academic_year_start_date { Date.new(start_year, 9) }

    after(:build) { |cohort| Rails.logger.debug("seeded cohort #{cohort.start_year}") }
  end
end
