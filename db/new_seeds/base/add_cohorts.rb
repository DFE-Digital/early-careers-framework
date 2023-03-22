# frozen_string_literal: true

# Cohort 2020
cohort_2020 = FactoryBot.create(:seed_cohort, start_year: 2020)

# Ensures Cohort.next is always created
academic_year_start_month = cohort_2020.academic_year_start_date.month
next_cohort_start_year = Date.current.year + (Date.current.month < academic_year_start_month ? 0 : 1)
(2021..next_cohort_start_year).to_a.each { |start_year| FactoryBot.create(:seed_cohort, start_year:) }
