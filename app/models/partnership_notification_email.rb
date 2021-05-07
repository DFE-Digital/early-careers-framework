# frozen_string_literal: true

class PartnershipNotificationEmail < ApplicationRecord
  belongs_to :partnerable, polymorphic: true
  has_one :nomination_email
  delegate :school, to: :partnerable, allow_nil: false
  delegate :lead_provider, to: :partnerable, allow_nil: false
  delegate :delivery_partner, to: :partnerable, allow_nil: true
  delegate :cohort, to: :partnerable, allow_nil: false
  delegate :challenge_deadline, to: :partnerable

  enum email_type: {
    induction_coordinator_email: "induction_coordinator_email",
    induction_coordinator_reminder_email: "induction_coordinator_reminder_email",
    school_email: "school_email",
    school_reminder_email: "school_reminder_email",
  }
end
