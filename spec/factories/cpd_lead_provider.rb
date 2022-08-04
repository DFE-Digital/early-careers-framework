# frozen_string_literal: true

FactoryBot.define do
  factory :cpd_lead_provider do
    name  { Faker::Company.name }

    trait :with_lead_provider do
      lead_provider { create(:lead_provider, name:) }
    end

    trait :with_npq_lead_provider do
      npq_lead_provider
    end
  end
end
