# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_school_cohort, class: "SchoolCohort") do
    school { association(:seed_school) }
    cohort { association(:cohort) }
  end
end
