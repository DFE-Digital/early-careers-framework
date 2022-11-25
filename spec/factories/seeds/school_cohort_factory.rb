# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_school_cohort, class: "SchoolCohort") do
    school { association(:seed_school) }
    cohort { association(:seed_cohort) }
    induction_programme_choice { "full_induction_programme" }

    trait(:cip) { induction_programme_choice { "core_induction_programme" } }

    after(:build) do |sc|
      Rails.logger.debug("seeded school cohort #{sc.cohort.start_year} for #{sc.school.name}")
    end
  end
end
