# frozen_string_literal: true

FactoryBot.define do
  factory :cpd_lead_provider do
    name  { Faker::Company.name }

    trait :with_lead_provider do
      after(:create) do |cpd_lead_provider|
        create(:lead_provider, name: cpd_lead_provider.name, cpd_lead_provider:)
      end
    end

    trait :with_npq_lead_provider do
      after(:create) do |cpd_lead_provider|
        create(:npq_lead_provider, name: cpd_lead_provider.name, cpd_lead_provider:)
      end
    end
  end
end
