# frozen_string_literal: true

class DeliveryPartner < ApplicationRecord
  has_many :provider_relationships
  has_many :lead_providers, through: :provider_relationships
  has_many :delivery_partner_profiles
  has_many :users, through: :delivery_partner_profiles
end
