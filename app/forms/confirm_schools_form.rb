# frozen_string_literal: true

class ConfirmSchoolsForm
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :school_ids, :delivery_partner_id, :source, :cohort_id, :lead_provider_id

  def save!
    ActiveRecord::Base.transaction do
      school_ids.each do |school_id|
        partnership = if SchoolCohort.find_by(school_id: school_id, cohort_id: cohort_id)&.core_induction_programme?
                        Partnership.create!(
                          school_id: school_id,
                          cohort_id: cohort_id,
                          delivery_partner_id: delivery_partner_id,
                          lead_provider_id: lead_provider_id,
                          pending: true,
                        )
                      else
                        Partnership.create!(
                          school_id: school_id,
                          cohort_id: cohort_id,
                          delivery_partner_id: delivery_partner_id,
                          lead_provider_id: lead_provider_id,
                        )
                      end

        PartnershipNotificationService.schedule_notifications(partnership)
      end
    end
  end

  def delivery_partner
    DeliveryPartner.find(delivery_partner_id)
  end
end
