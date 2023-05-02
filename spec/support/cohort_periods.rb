# frozen_string_literal: true

# time travel to a date inside the registration window priot to the cohort academic year start
def inside_registration_window(cohort: Cohort.next, &block)
  travel_to(cohort.registration_start_date + 1.week, &block)
end

# time travel to a date inside of the cohort automatic assignment period
def inside_auto_assignment_window(cohort: Cohort.current, &block)
  travel_to(cohort.automatic_assignment_period_end_date - 1.week, &block)
end

# time travel to a date outside of the cohort automatic assignment period
def outside_auto_assignment_window(cohort: Cohort.current, &block)
  travel_to(cohort.automatic_assignment_period_end_date + 1.week, &block)
end
