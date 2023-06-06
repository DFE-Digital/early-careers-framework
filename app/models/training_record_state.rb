# frozen_string_literal: true

class TrainingRecordState < ApplicationRecord
  belongs_to :participant_profile
  belongs_to :school, optional: true
  belongs_to :lead_provider, optional: true
  belongs_to :delivery_partner, optional: true
  belongs_to :appropriate_body, optional: true

  scope :changed_most_recently_first, -> { order(changed_at: "desc") }

  def self.latest_for(participant_profile:, school: nil, appropriate_body: nil, delivery_partner: nil, lead_provider: nil)
    params = {
      participant_profile_id: participant_profile.id,
      school_id: school&.id,
      appropriate_body_id: appropriate_body&.id,
      delivery_partner_id: delivery_partner&.id,
      lead_provider_id: lead_provider&.id,
    }.compact

    Rails.logger.debug("Searching with: #{params}")

    where(**params).changed_most_recently_first.first
  end
end
