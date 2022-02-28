# frozen_string_literal: true

FactoryBot.define do
  factory :provider_relationship do
    cohort { Cohort.find_or_create_by!(start_year: 2021) }
    lead_provider
    delivery_partner { create :delivery_partner }
  end
end
