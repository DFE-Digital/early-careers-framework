# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_school_cohort, class: "SchoolCohort") do
    induction_programme_choice { SchoolCohort.induction_programme_choices.values.sample }

    trait(:with_school) { school { association(:seed_school) } }
    trait(:with_cohort) { cohort { association(:seed_cohort) } }
    trait(:with_appropriate_body) { appropriate_body { association(:seed_appropriate_body) } }

    trait(:fip) { induction_programme_choice { "full_induction_programme" } }
    trait(:cip) { induction_programme_choice { "core_induction_programme" } }
    trait(:no_early_career_teachers) { induction_programme_choice { "no_early_career_teachers" } }
    trait(:design_our_own) { induction_programme_choice { "design_our_own" } }
    trait(:school_funded_fip) { induction_programme_choice { "school_funded_fip" } }

    trait(:starting_in_2021) { cohort { create(:cohort, start_year: 2021) } }
    trait(:starting_in_2022) { cohort { create(:cohort, start_year: 2022) } }

    trait(:valid) do
      with_school
      starting_in_2022
    end

    after(:build) do |sc|
      if sc.cohort.present? && sc.school.present?
        Rails.logger.debug("seeded school cohort #{sc.cohort.start_year} for #{sc.school.name}")
      else
        Rails.logger.debug("seeded incomplete school cohort")
      end
    end
  end
end
