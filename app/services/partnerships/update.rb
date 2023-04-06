# frozen_string_literal: true

module Partnerships
  class Update
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :partnership
    attribute :delivery_partner_id

    validates :partnership, :delivery_partner_id, presence: true
    validate :validate_delivery_partner

    def call
      return if invalid?
      return partnership if partnership.delivery_partner == delivery_partner

      ::Partnerships::Report.call(
        school_id: school.id,
        cohort_id: cohort.id,
        lead_provider_id: lead_provider.id,
        delivery_partner_id: delivery_partner.id,
      )
    end

  private

    delegate :school, :cohort, :lead_provider,
             to: :partnership

    def delivery_partner
      @delivery_partner ||= DeliveryPartner.find_by(id: delivery_partner_id)
    end

    def delivery_partner_has_provider_relationship?
      delivery_partner.provider_relationships.where(cohort:, lead_provider:).exists?
    end

    def duplicate_delivery_partner_request?
      Partnership.where(school:, cohort:, lead_provider:, delivery_partner:).where.not(id: partnership.id).exists?
    end

    def validate_delivery_partner
      return if delivery_partner_id.blank?

      if delivery_partner
        if !delivery_partner_has_provider_relationship?
          errors.add(:delivery_partner_id, :no_relationship)
        elsif partnership.challenged?
          errors.add(:delivery_partner_id, :partnership_challenged)
        elsif duplicate_delivery_partner_request?
          errors.add(:delivery_partner_id, :duplicate_delivery_partner)
        end
      else
        errors.add(:delivery_partner_id, :invalid)
      end
    end
  end
end
