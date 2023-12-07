# frozen_string_literal: true

FactoryBot.define do
  factory :npq_reg_lead_provider, class: NPQRegistration::LeadProvider do
    sequence(:name) { |n| "Lead Provider #{n}" }
  end
end
