# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_induction_programme, class: "InductionProgramme") do
    training_programme { "full_induction_programme" }

    trait(:fip) { training_programme { "full_induction_programme" } }
    trait(:cip) { training_programme { "core_induction_programme" } }
    trait(:design_our_own) { training_programme { "design_our_own" } }
    trait(:school_funnded_fip) { training_programme { "school_funnded_fip" } }

    trait(:with_school_cohort) { association(:school_cohort, factory: %i[seed_school_cohort valid]) }
    trait(:with_school) { association(:school, factory: :seed_school) }

    trait(:valid) do
      fip
      with_school_cohort
    end

    after(:build) do |ip|
      if ip.school_cohort.present?
        Rails.logger.debug("seeded induction_programme for school #{ip.school_cohort.school.name}")
      else
        Rails.logger.debug("seeded incomplete induction programme")
      end
    end
  end
end
