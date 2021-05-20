# frozen_string_literal: true

class ConfirmSchoolsForm
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :school_ids, :delivery_partner_id, :source, :cohort_id, :lead_provider_id

  def save!
    ActiveRecord::Base.transaction do
      school_ids.each do |school_id|
        school_cohort = SchoolCohort.find_by(school_id: school_id, cohort_id: cohort_id)
        partnership_is_pending = school_cohort&.core_induction_programme? || false
        partnership = Partnership.create!(
          school_id: school_id,
          cohort_id: cohort_id,
          delivery_partner_id: delivery_partner_id,
          lead_provider_id: lead_provider_id,
          pending: partnership_is_pending,
        )

        if school_cohort.nil?
          SchoolCohort.create!(
            school_id: school_id,
            cohort_id: cohort_id,
            induction_programme_choice: "full_induction_programme",
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
