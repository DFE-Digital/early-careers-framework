# frozen_string_literal: true

class DeliveryPartnerForm
  include ActiveModel::Model

  attr_accessor :name, :lead_providers, :provider_relationships

  def available_lead_providers
    LeadProvider.select { |lp| lp.cohorts.any? }
  end

  def chosen_provider_relationships
    provider_relationships.map do |relationship|
      ProviderRelationship.new(
        cohort: Cohort.find(relationship["cohort_id"]),
        lead_provider: LeadProvider.find(relationship["lead_provider_id"]),
      )
    end
  end
end
