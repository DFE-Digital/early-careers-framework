# frozen_string_literal: true

class DeliveryPartner < ApplicationRecord
  has_many :provider_relationships
  has_many :lead_providers, through: :provider_relationships

  def cohorts_with_provider(lead_provider)
    provider_relationships.joins(:cohort).includes(:cohort).where(lead_provider: lead_provider).map(&:cohort)
  end
end
