# frozen_string_literal: true

class PartnershipNotificationEmail < ApplicationRecord
  belongs_to :partnership
  has_one :nomination_email, dependent: :nullify
  delegate :school, to: :partnership, allow_nil: false
  delegate :lead_provider, to: :partnership, allow_nil: false
  delegate :delivery_partner, to: :partnership, allow_nil: true
  delegate :cohort, to: :partnership, allow_nil: false
  delegate :challenge_deadline, to: :partnership

  enum email_type: {
    induction_coordinator_email: "induction_coordinator_email",
    induction_coordinator_reminder_email: "induction_coordinator_reminder_email",
    school_email: "school_email",
    school_reminder_email: "school_reminder_email",
  }
end
