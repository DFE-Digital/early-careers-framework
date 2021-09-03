# frozen_string_literal: true

class NPQValidationData < ApplicationRecord
  # TODO: Rename table
  self.table_name = "npq_profiles"

  has_one :profile, class_name: "ParticipantProfile::NPQ", foreign_key: :id, touch: true
  belongs_to :user
  belongs_to :npq_lead_provider
  belongs_to :npq_course

  after_save :push_enrollment_to_big_query

  enum headteacher_status: {
    no: "no",
    yes_when_course_starts: "yes_when_course_starts",
    yes_in_first_two_years: "yes_in_first_two_years",
    yes_over_two_years: "yes_over_two_years",
  }

  enum funding_choice: {
    school: "school",
    trust: "trust",
    self: "self",
    another: "another",
  }

  enum lead_provider_approval_status: {
    pending: "pending",
    accepted: "accepted",
    rejected: "rejected",
  }

  validate :validate_rejected_status_cannot_change
  validate :validate_accepted_status_cannot_change

  def validate_rejected_status_cannot_change
    if lead_provider_approval_status_changed?(from: "rejected")
      errors.add(:lead_provider_approval_status, :invalid, message: "Once rejected an application cannot change state")
    end
  end

  def validate_accepted_status_cannot_change
    if lead_provider_approval_status_changed?(from: "accepted")
      errors.add(:lead_provider_approval_status, :invalid, message: "Once accepted an application cannot change state")
    end
  end

private

  def push_enrollment_to_big_query
    if (saved_changes.keys & %w[id lead_provider_approval_status]).present?
      NPQ::StreamBigQueryEnrollmentJob.perform_later(npq_validation_data_id: id)
    end
  end
end
