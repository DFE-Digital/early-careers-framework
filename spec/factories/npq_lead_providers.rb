# frozen_string_literal: true

FactoryBot.define do
  factory :npq_lead_provider do
    sequence(:name) { |n| "NPQ Lead Provider #{n}" }
    cpd_lead_provider
  end
end
