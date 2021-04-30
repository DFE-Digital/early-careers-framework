# frozen_string_literal: true

class ConfirmSchoolsForm
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :school_ids, :delivery_partner_id, :source, :cohort_id, :lead_provider_id

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
end
