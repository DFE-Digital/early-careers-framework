# frozen_string_literal: true

FactoryBot.define do
  factory :delivery_partner_profile do
    user
    delivery_partner
  end
end
