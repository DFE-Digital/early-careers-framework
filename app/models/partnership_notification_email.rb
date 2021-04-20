# frozen_string_literal: true

class PartnershipNotificationEmail < ApplicationRecord
  TOKEN_LIFETIME = 14.days

  belongs_to :partnership
  has_one :nomination_email
  delegate :school, to: :partnership, allow_nil: false
  delegate :lead_provider, to: :partnership, allow_nil: false
  delegate :delivery_partner, to: :partnership, allow_nil: true
  delegate :cohort, to: :partnership, allow_nil: false

  enum email_type: {
    induction_coordinator_email: "induction_coordinator_email",
    school_email: "school_email",
  }

  def token_expired?
    created_at + TOKEN_LIFETIME < Time.zone.now
  end
end
