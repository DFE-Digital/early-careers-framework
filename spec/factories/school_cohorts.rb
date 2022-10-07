# frozen_string_literal: true

FactoryBot.define do
  factory :school_cohort do
    transient do
      lead_provider { nil }
      delivery_partner { create(:delivery_partner) }
    end

    cohort { Cohort.current || create(:cohort, :current) }
    school { create(:school) }
    induction_programme_choice { %w[core_induction_programme full_induction_programme].sample }

    after(:create) do |school_cohort, evaluator|
      if evaluator.lead_provider
        create(:partnership,
               school: school_cohort.school,
               cohort: school_cohort.cohort,
               delivery_partner: evaluator.delivery_partner,
               lead_provider: evaluator.lead_provider)
      end
    end

    trait :with_ecf_standard_schedule do
      after(:create) do |school_cohort|
        create(:ecf_schedule, cohort: school_cohort.cohort)
      end
    end

    trait :sparsity_uplift do
      school { create(:school, :sparsity_uplift) }
    end

    trait :pupil_premium_uplift do
      school { create(:school, :pupil_premium_uplift) }
    end

    trait :fip do
      induction_programme_choice { "full_induction_programme" }
    end

    trait :with_induction_programme do
      transient do
        core_induction_programme { nil }
      end

      after(:create) do |school_cohort, evaluator|
        Induction::SetCohortInductionProgramme.call(
          school_cohort:,
          programme_choice: school_cohort.induction_programme_choice,
          core_induction_programme: evaluator.core_induction_programme,
        )
      end
    end

    trait :cip do
      induction_programme_choice { "core_induction_programme" }
    end

    trait :school_funded_fip do
      induction_programme_choice { "school_funded_fip" }
    end

    trait :consecutive_cohorts do
      cohort { create(:cohort, :consecutive_years) }
    end
  end
end
