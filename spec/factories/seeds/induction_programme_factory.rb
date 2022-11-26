# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_induction_programme, class: "InductionProgramme") do
    training_programme { "full_induction_programme" }

    trait(:fip) { training_programme { "full_induction_programme" } }
    trait(:cip) { training_programme { "core_induction_programme" } }
    trait(:design_our_own) { training_programme { "design_our_own" } }
    trait(:school_funnded_fip) { training_programme { "school_funnded_fip" } }

    trait(:with_school_cohort) { association(:school_cohort, factory: :seed_school_cohort) }
    trait(:with_school) { association(:school, factory: :seed_school) }

    after(:build) { |ip| Rails.logger.debug("seeded induction_programme for school #{ip.school_cohort.school.name}") }
  end
end
