# frozen_string_literal: true

FactoryBot.define do
  factory :lead_provider_profile do
    user
    lead_provider
  end
end
