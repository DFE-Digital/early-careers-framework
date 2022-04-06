# frozen_string_literal: true

FactoryBot.define do
  factory :provider_relationship do
    cohort { Cohort.current || create(:cohort, :current) }
    lead_provider
    delivery_partner { create :delivery_partner }
  end
end
