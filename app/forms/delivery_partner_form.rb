# frozen_string_literal: true

class DeliveryPartnerForm
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :name, :lead_provider_ids, :provider_relationship_hashes
  validates :name, presence: { message: "Enter a name" }, on: %i[name update]
  validate :lead_providers_validation, on: %i[lead_providers update]
  validate :cohorts_validation, on: %i[cohorts update]

  def attributes
    { name: nil, lead_provider_ids: nil, provider_relationship_hashes: nil }
  end

  # TODO: ECF-RP-328
  def self.provider_relationship_value(lead_provider, cohort)
    { "lead_provider_id" => lead_provider.id, "cohort_id" => cohort.id }.to_json
  end

  def available_lead_providers
    LeadProvider.joins(:cohorts).includes(:cohorts).select { |lead_provider| lead_provider.cohorts.any? }
  end

  def chosen_provider_relationships
    provider_relationships
      &.filter { |relationship_params| lead_provider_ids&.include?(relationship_params["lead_provider_id"]) }
      &.map { |relationship_params| ProviderRelationship.find_or_initialize_by(relationship_params) }
  end

  def display_lead_provider_details
    chosen_provider_relationships.group_by(&:lead_provider).map do |lps_to_relationships|
      {
        name: lps_to_relationships.first.name,
        chosen_cohorts: lps_to_relationships.second.map { |relationship| relationship.cohort.display_name }.join(", "),
      }
    end
  end

  def provider_relationships
    provider_relationship_hashes
        &.filter { |hash| hash.present? }
        &.map { |provider_relationship_hash| JSON.parse(provider_relationship_hash) }
  end

  def save!
    delivery_partner = DeliveryPartner.new(name: name)

    ActiveRecord::Base.transaction do
      delivery_partner.save!
      chosen_provider_relationships.each do |provider_relationship|
        provider_relationship.delivery_partner = delivery_partner
        provider_relationship.save!
      end
    end

    delivery_partner
  end

  def update!(delivery_partner)
    delivery_partner.name = name
    ActiveRecord::Base.transaction do
      delivery_partner.save!
      chosen_provider_relationships.each do |provider_relationship|
        provider_relationship.delivery_partner = delivery_partner
        provider_relationship.save!
      end

      delivery_partner.provider_relationships.where.not(id: chosen_provider_relationships).discard_all!
    end
  end

private

  def lead_providers_validation
    unless lead_provider_ids&.filter(&:present?)&.any?
      errors.add(:lead_provider_ids, :blank, message: "Choose at least one")
    end
  end

  def cohorts_validation
    # Ensure all selected lead providers have at least one selected cohort
    # This is indicated by the presence of a provider relationship for that lead provider
    lead_provider_ids&.filter(&:present?)&.each do |lead_provider_id|
      unless chosen_provider_relationships.pluck(:lead_provider_id).include?(lead_provider_id)
        errors.add(:provider_relationship_hashes, :blank, message: "Choose at least one cohort for every lead provider")
        break
      end
    end
  end
end
