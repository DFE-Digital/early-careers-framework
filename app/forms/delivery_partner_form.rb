# frozen_string_literal: true

class DeliveryPartnerForm
  include ActiveModel::Model

  attr_accessor :name, :lead_providers, :provider_relationships
  validate :lead_providers_and_cohorts_validation

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

  def populate_provider_relationships(params)
    self.lead_providers ||= []
    self.provider_relationships ||= []

    lead_provider_ids = params.dig(:delivery_partner_form, :lead_providers)&.keep_if(&:present?)
    lead_provider_ids.each do |lead_provider_id|
      lead_providers.push(LeadProvider.find(lead_provider_id))
    end

    lead_providers.each do |lead_provider|
      chosen_cohorts = params.dig(
        :delivery_partner_form,
        lead_provider.id.to_sym,
        :cohorts,
      )&.keep_if(&:present?)

      chosen_cohorts&.each do |cohort|
        provider_relationships.push ProviderRelationship.new(
          cohort_id: cohort,
          lead_provider: lead_provider,
        )
      end
    end
  end

private

  def lead_providers_and_cohorts_validation
    unless lead_providers.any?
      errors.add(:lead_providers, :blank, message: "Choose at least one")
      return
    end

    # Ensure all selected lead providers have at least one selected cohort
    # This is indicated by the presence of a provider relationship for that lead provider
    lead_providers.each do |lead_provider|
      unless provider_relationships.keep_if { |provider_relationship| provider_relationship.lead_provider == lead_provider }.any?
        errors.add(:lead_providers, :blank, message: "Choose at least one cohort for every selected lead provider")
        break
      end
    end
  end
end
