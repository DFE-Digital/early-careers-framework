# frozen_string_literal: true

class DeliveryPartner < ApplicationRecord
  has_many :provider_relationships
  has_many :lead_providers, through: :provider_relationships
end
