# frozen_string_literal: true

FactoryBot.define do
  factory :npq_lead_provider do
    cpd_lead_provider

    sequence(:name) { |n| "NPQ Lead Provider #{n}" }
  end
end
