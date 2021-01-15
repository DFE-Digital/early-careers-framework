# frozen_string_literal: true

FactoryBot.define do
  factory :lead_provider_cip do
    lead_provider { nil }
    cohort { nil }
    cip { nil }
  end
end
