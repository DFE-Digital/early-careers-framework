# frozen_string_literal: true

FactoryBot.define do
  factory :induction_programme do
    school_cohort
    training_programme { %w[design_our_own school_funded_fip].sample }

    trait :fip do
      partnership
      training_programme { "full_induction_programme" }
    end

    trait :cip do
      core_induction_programme
      training_programme { "core_induction_programme" }
    end

    trait :sffip do
      partnership
      training_programme { "school_funded_fip" }
    end
  end
end
