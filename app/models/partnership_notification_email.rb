# frozen_string_literal: true

class PartnershipNotificationEmail < ApplicationRecord
  belongs_to :partnership
  has_one :nomination_email, dependent: :nullify

  delegate :school, :lead_provider, :cohort, :challenge_deadline, to: :partnership
  delegate :delivery_partner, to: :partnership, allow_nil: true

  enum email_type: {
    induction_coordinator_email: "induction_coordinator_email",
    induction_coordinator_reminder_email: "induction_coordinator_reminder_email",
    school_email: "school_email",
    school_reminder_email: "school_reminder_email",
    nominate_sit_email: "nominate_sit_email",
  }
end
