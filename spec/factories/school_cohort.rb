# frozen_string_literal: true

FactoryBot.define do
  factory :school_cohort do
    cohort
    school
    induction_programme_choice { "core_induction_programme" }
  end
end
