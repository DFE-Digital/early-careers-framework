# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_school_cohort, class: "SchoolCohort") do
    induction_programme_choice { "full_induction_programme" }

    trait(:with_school) { school { association(:seed_school) } }
    trait(:with_cohort) { cohort { association(:seed_cohort) } }

    trait(:fip) { induction_programme_choice { "full_induction_programme" } }
    trait(:cip) { induction_programme_choice { "core_induction_programme" } }

    trait(:valid) do
      with_school
      with_cohort
    end

    trait(:starting_in_2021) { cohort { Cohort.find_by!(start_year: 2021) } }
    trait(:starting_in_2022) { cohort { Cohort.find_by!(start_year: 2022) } }

    after(:build) do |sc|
      if sc.cohort.present? && sc.school.present?
        Rails.logger.debug("seeded school cohort #{sc.cohort.start_year} for #{sc.school.name}")
      else
        Rails.logger.debug("seeded incomplete school cohort")
      end
    end
  end
end
