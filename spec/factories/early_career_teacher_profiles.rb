# frozen_string_literal: true

FactoryBot.define do
  factory :early_career_teacher_profile do
    user
    school

    trait :sparsity_uplift do
      sparsity_uplift { true }
    end
  end
end
