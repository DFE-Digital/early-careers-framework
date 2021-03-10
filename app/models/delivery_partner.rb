# frozen_string_literal: true

class DeliveryPartner < DiscardableRecord
  has_many :provider_relationships
  has_many :lead_providers, through: :provider_relationships

  after_discard do
    provider_relationships.discard_all
  end

  def cohorts_with_provider(lead_provider)
    provider_relationships.joins(:cohort).includes(:cohort).where(lead_provider: lead_provider).map(&:cohort)
  end
end
