# frozen_string_literal: true

class TrainingRecordState < ApplicationRecord
  belongs_to :participant_profile, inverse_of: :training_record_states
  belongs_to :school, inverse_of: :training_record_states
  belongs_to :lead_provider, inverse_of: :training_record_states
  belongs_to :delivery_partner, inverse_of: :training_record_states
  belongs_to :appropriate_body, inverse_of: :training_record_states
  belongs_to :induction_record, inverse_of: :training_record_state

  enum validation_state: {
    different_trn: "different_trn",
    request_for_details_delivered: "request_for_details_delivered",
    request_for_details_failed: "request_for_details_failed",
    request_for_details_submitted: "request_for_details_submitted",
    validation_not_started: "validation_not_started",
    internal_error: "internal_error",
    tra_record_not_found: "tra_record_not_found",
    valid: "valid",
  }, _prefix: "validation_status"

  enum training_eligibility_state: {
    checks_not_complete: "checks_not_complete",
    active_flags: "active_flags",
    not_allowed: "not_allowed",
    eligible_for_mentor_training: "eligible_for_mentor_training",
    not_yet_mentoring: "not_yet_mentoring",
    duplicate_profile: "duplicate_profile",
    not_qualified: "not_qualified",
    exempt_from_induction: "exempt_from_induction",
    previous_induction: "previous_induction",
    tra_record_not_found: "tra_record_not_found",
    eligible_for_induction_training: "eligible_for_induction_training",
  }, _prefix: "training_eligibility_status"

  enum fip_funding_eligibility_state: {
    checks_not_complete: "checks_not_complete",
    eligible_for_fip_funding: "eligible_for_fip_funding",
    active_flags: "active_flags",
    not_allowed: "not_allowed",
    ineligible_ero_secondary: "ineligible_ero_secondary",
    ineligible_ero_primary: "ineligible_ero_primary",
    ineligible_ero: "ineligible_ero",
    ineligible_secondary: "ineligible_secondary",
    eligible_for_mentor_funding_primary: "eligible_for_mentor_funding_primary",
    eligible_for_mentor_funding: "eligible_for_mentor_funding",
    no_induction_start: "no_induction_start",
    not_qualified: "not_qualified",
    duplicate_profile: "duplicate_profile",
    exempt_from_induction: "exempt_from_induction",
    previous_induction: "previous_induction",
    tra_record_not_found: "tra_record_not_found",
  }, _prefix: "fip_funding_eligibility_status"

  enum mentoring_state: {
    active_mentoring_ero: "active_mentoring_ero",
    active_mentoring: "active_mentoring",
    not_yet_mentoring_ero: "not_yet_mentoring_ero",
    not_yet_mentoring: "not_yet_mentoring",
    not_a_mentor: "not_a_mentor",
  }, _prefix: "mentoring_status"

  enum training_state: {
    no_longer_involved: "no_longer_involved",
    leaving: "leaving",
    left: "left",
    joining: "joining",
    withdrawn_programme: "withdrawn_programme",
    withdrawn_training: "withdrawn_training",
    deferred_training: "deferred_training",
    completed_training: "completed_training",
    registered_for_fip_no_partner: "registered_for_fip_no_partner",
    active_fip_training: "active_fip_training",
    registered_for_fip_training: "registered_for_fip_training",
    active_cip_training: "active_cip_training",
    registered_for_cip_training: "registered_for_cip_training",
    active_diy_training: "active_diy_training",
    registered_for_diy_training: "registered_for_diy_training",
    not_registered_for_training: "not_registered_for_training",
  }, _prefix: "training_status"

  enum record_state: {
    different_trn: "different_trn",
    request_for_details_delivered: "request_for_details_delivered",
    request_for_details_failed: "request_for_details_failed",
    request_for_details_submitted: "request_for_details_submitted",
    validation_not_started: "validation_not_started",
    internal_error: "internal_error",
    tra_record_not_found: "tra_record_not_found",
    checks_not_complete: "checks_not_complete",
    active_flags: "active_flags",
    not_allowed: "not_allowed",
    duplicate_profile: "duplicate_profile",
    not_qualified: "not_qualified",
    exempt_from_induction: "exempt_from_induction",
    previous_induction: "previous_induction",
    no_induction_start: "no_induction_start",
    active_mentoring_ero: "active_mentoring_ero",
    active_mentoring: "active_mentoring",
    not_yet_mentoring_ero: "not_yet_mentoring_ero",
    not_yet_mentoring: "not_yet_mentoring",
    no_longer_involved: "no_longer_involved",
    leaving: "leaving",
    left: "left",
    joining: "joining",
    withdrawn_programme: "withdrawn_programme",
    withdrawn_training: "withdrawn_training",
    deferred_training: "deferred_training",
    completed_training: "completed_training",
    registered_for_fip_no_partner: "registered_for_fip_no_partner",
    active_fip_training: "active_fip_training",
    registered_for_fip_training: "registered_for_fip_training",
    registered_for_cip_training: "registered_for_cip_training",
    active_cip_training: "active_cip_training",
    active_diy_training: "active_diy_training",
    registered_for_diy_training: "registered_for_diy_training",
    not_registered_for_training: "not_registered_for_training",
  }, _prefix: "is"

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: true, cascade: false)
  end

  def self.for(participant_profile:, induction_record: nil, lead_provider: nil, delivery_partner: nil, appropriate_body: nil, school: nil)
    if school.present?
      where(participant_profile:, school:)
    elsif lead_provider.present?
      where(participant_profile:, lead_provider:)
    elsif delivery_partner.present?
      where(participant_profile:, delivery_partner:)
    elsif appropriate_body.present?
      where(participant_profile:, appropriate_body:)
    elsif induction_record.present?
      where(participant_profile:, induction_record:)
    else
      where(participant_profile:)
    end
  end

  def self.latest_for(participant_profile:, induction_record: nil, lead_provider: nil, delivery_partner: nil, appropriate_body: nil, school: nil)
    self.for(participant_profile:, induction_record:, lead_provider:, delivery_partner:, appropriate_body:, school:).latest
  end

  def self.latest
    order(changed_at: :desc).first
  end

  def readonly?
    true
  end

  def default
    TrainingRecordState.new
  end
end
