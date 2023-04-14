# frozen_string_literal: true

module Partnerships
  class Create
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :cohort
    attribute :school_id
    attribute :lead_provider_id
    attribute :delivery_partner_id

    validates :cohort, :school_id, :lead_provider_id, :delivery_partner_id, presence: true
    validate :validate_cohort
    validate :validate_lead_provider
    validate :validate_school
    validate :validate_delivery_partner

    def call
      return false if invalid?

      ::Partnerships::Report.call(
        school_id:,
        cohort_id: cohort_record.id,
        delivery_partner_id:,
        lead_provider_id:,
      )
    end

  private

    def cohort_record
      @cohort_record ||= Cohort.find_by(start_year: cohort)
    end

    def lead_provider
      @lead_provider ||= LeadProvider.find_by(id: lead_provider_id)
    end

    def school
      @school ||= School.find_by(id: school_id)
    end

    def delivery_partner
      @delivery_partner ||= DeliveryPartner.find_by(id: delivery_partner_id)
    end

    def delivery_partner_has_provider_relationship?
      delivery_partner.provider_relationships.where(cohort: cohort_record, lead_provider:).exists?
    end

    def validate_cohort
      return if cohort.blank?

      unless cohort_record
        errors.add(:cohort, :invalid)
      end
    end

    def validate_lead_provider
      return if lead_provider_id.blank?

      unless lead_provider
        errors.add(:lead_provider_id, :invalid)
      end
    end

    def validate_delivery_partner
      return if delivery_partner_id.blank?

      if delivery_partner
        if !delivery_partner_has_provider_relationship?
          errors.add(:delivery_partner_id, :no_relationship)
        elsif errors.empty? && duplicate_delivery_partner_request?
          errors.add(:delivery_partner_id, :duplicate_delivery_partner)
        end
      else
        errors.add(:delivery_partner_id, :invalid)
      end
    end

    def validate_school
      return if school_id.blank?

      if !school
        errors.add(:school_id, :invalid)
      elsif school.cip_only?
        errors.add(:school_id, :funding_error)
      elsif !school.eligible?
        errors.add(:school_id, :ineligible_error)
      elsif school.lead_provider(cohort_record.start_year) == lead_provider
        errors.add(:school_id, :already_confirmed)
      elsif school.lead_provider(cohort_record.start_year).present? || has_previous_cohort_and_matching_lead_provider?
        errors.add(:school_id, :recruited_by_other_provider)
      end
    end

    def has_previous_cohort_and_matching_lead_provider?
      previous_year_lead_provider = school.lead_provider(cohort_record.start_year - 1)

      return false if previous_year_lead_provider.blank?

      previous_year_lead_provider != lead_provider && school.school_cohorts.find_by(cohort: cohort_record).blank?
    end

    def duplicate_delivery_partner_request?
      Partnership.where(school:, cohort: cohort_record, lead_provider:, delivery_partner:).exists?
    end
  end
end
