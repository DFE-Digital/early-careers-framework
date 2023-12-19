# frozen_string_literal: true

FactoryBot.define do
  factory :npq_reg_source_lead_provider, class: Migration::NPQRegistration::Source::LeadProvider do
    sequence(:name) { |n| "Lead Provider #{n}" }
  end
end
