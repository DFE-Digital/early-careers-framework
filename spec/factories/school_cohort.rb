# frozen_string_literal: true

FactoryBot.define do
  factory :school_cohort do
    cohort { create(:cohort, :current) }
    school
    induction_programme_choice { %w[core_induction_programme full_induction_programme].sample }

    trait :fip do
      induction_programme_choice { "full_induction_programme" }
    end

    trait :cip do
      induction_programme_choice { "core_induction_programme" }
    end
  end
end
