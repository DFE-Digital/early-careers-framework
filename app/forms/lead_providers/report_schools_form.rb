# frozen_string_literal: true

module LeadProviders
  class ReportSchoolsForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Serialization

    attribute :school_ids
    attribute :delivery_partner_id
    attribute :source
    attribute :cohort_id
    attribute :lead_provider_id

    validates :delivery_partner_id, presence: { message: "Choose a delivery partner" }, on: :delivery_partner

    def save!
      ActiveRecord::Base.transaction do
        school_ids.each do |school_id|
          partnership = Partnership.create!(
            school_id: school_id,
            cohort_id: cohort_id,
            delivery_partner_id: delivery_partner_id,
            lead_provider_id: lead_provider_id,
          )

          PartnershipNotificationService.new.delay.notify(partnership)
        end
      end
    end

    def delivery_partner
      @delivery_partner ||= DeliveryPartner.find_by(id: delivery_partner_id)
    end

    def cohort
      @cohort ||= Cohort.find_by(id: cohort_id)
    end
  end
end
