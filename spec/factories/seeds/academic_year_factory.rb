# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_academic_year, class: "AcademicYear") do
    sequence(:start_year) { Faker::Number.unique.between(from: 2050, to: 9999) }

    start_date { Date.new(start_year, 9, 1) }

    initialize_with do
      AcademicYear.find_by(start_year:) || new(**attributes)
    end

    trait(:with_cohort) { association :cohort, :seed_cohort, start_year:, academic_year_start_date: start_date }

    trait(:valid) do
      :with_cohort
    end

    after(:build) { |academic_year| Rails.logger.debug("seeded academic year #{academic_year.id}") }
  end
end
