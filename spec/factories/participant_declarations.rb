# frozen_string_literal: true

FactoryBot.define do
  factory :participant_declaration do
    early_career_teacher_profile
    lead_provider
    declaration_date { Time.zone.now - 1.week }
    declaration_type { "started" }

    trait :sparsity_uplift do
      association :early_career_teacher_profile, :sparsity_uplift
    end
  end
end
