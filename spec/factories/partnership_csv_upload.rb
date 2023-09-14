# frozen_string_literal: true

FactoryBot.define do
  factory :partnership_csv_upload do
    lead_provider
    delivery_partner
    cohort
    uploaded_urns { %w[111111 222222 333333 444444] }
  end
end
