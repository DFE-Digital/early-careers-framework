# frozen_string_literal: true

class TrainingRecordState < ApplicationRecord
  belongs_to :participant_profile, inverse_of: :training_record_states

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
    not_yet_mentoring: "not_yet_mentoring",
    eligible_for_mentor_training_no_partner: "eligible_for_mentor_training_no_partner",
    eligible_for_mentor_training: "eligible_for_mentor_training",
    secondary_profile: "secondary_profile",
    duplicate_profile: "duplicate_profile",
    not_qualified: "not_qualified",
    exempt_from_induction: "exempt_from_induction",
    previous_induction: "previous_induction",
    tra_record_not_found: "tra_record_not_found",
    eligible_for_induction_training_no_partner: "eligible_for_induction_training_no_partner",
    eligible_for_induction_training: "eligible_for_induction_training",
  }, _prefix: "training_eligibility_status"

  enum fip_funding_eligibility_state: {
    checks_not_complete: "checks_not_complete",
    active_flags: "active_flags",
    not_allowed: "not_allowed",
    ineligible_ero_secondary: "ineligible_ero_secondary",
    duplicate_profile_ero: "duplicate_profile_ero",
    ineligible_ero_primary: "ineligible_ero_primary",
    ineligible_ero: "ineligible_ero",
    ineligible_secondary: "ineligible_secondary",
    duplicate_profile: "duplicate_profile",
    eligible_for_mentor_funding_primary: "eligible_for_mentor_funding_primary",
    eligible_for_mentor_funding: "eligible_for_mentor_funding",
    no_induction_start: "no_induction_start",
    not_qualified: "not_qualified",
    exempt_from_induction: "exempt_from_induction",
    previous_induction: "previous_induction",
    tra_record_not_found: "tra_record_not_found",
    eligible_for_fip_funding: "eligible_for_fip_funding",
  }, _prefix: "fip_funding_eligibility_status"

  enum training_state: {
    withdrawn_programme: "withdrawn_programme",
    withdrawn_training: "withdrawn_training",
    deferred_training: "deferred_training",
    completed_training: "completed_training",
    no_longer_involved: "no_longer_involved",
    leaving: "leaving",
    left: "left",
    joining: "joining",
    active_fip_mentoring_no_partner: "active_fip_mentoring_no_partner",
    active_fip_mentoring_ero: "active_fip_mentoring_ero",
    active_fip_mentoring: "active_fip_mentoring",
    not_yet_mentoring_fip_no_partner: "not_yet_mentoring_fip_no_partner",
    not_yet_mentoring_fip_ero: "not_yet_mentoring_fip_ero",
    not_yet_mentoring_fip: "not_yet_mentoring_fip",
    active_cip_mentoring_no_partner: "active_cip_mentoring_no_partner",
    active_cip_mentoring_ero: "active_cip_mentoring_ero",
    active_cip_mentoring: "active_cip_mentoring",
    not_yet_mentoring_cip_no_partner: "not_yet_mentoring_cip_no_partner",
    not_yet_mentoring_cip_ero: "not_yet_mentoring_cip_ero",
    not_yet_mentoring_cip: "not_yet_mentoring_cip",
    registered_for_fip_no_partner: "registered_for_fip_no_partner",
    registered_for_fip_training: "registered_for_fip_training",
    active_fip_training: "active_fip_training",
    registered_for_cip_training: "registered_for_cip_training",
    active_cip_training: "active_cip_training",
    active_diy_training: "active_diy_training",
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
    not_yet_mentoring: "not_yet_mentoring",
    secondary_profile: "secondary_profile",
    duplicate_profile: "duplicate_profile",
    not_qualified: "not_qualified",
    exempt_from_induction: "exempt_from_induction",
    previous_induction: "previous_induction",

    ineligible_ero_secondary: "ineligible_ero_secondary",
    duplicate_ero_profile: "duplicate_ero_profile",
    ineligible_ero_primary: "ineligible_ero_primary",
    ineligible_ero: "ineligible_ero",
    ineligible_secondary: "ineligible_secondary",
    no_induction_start: "no_induction_start",

    withdrawn_programme: "withdrawn_programme",
    withdrawn_training: "withdrawn_training",
    deferred_training: "deferred_training",
    completed_training: "completed_training",
    no_longer_involved: "no_longer_involved",
    leaving: "leaving",
    left: "left",
    joining: "joining",
    active_fip_mentoring_no_partner: "active_fip_mentoring_no_partner",
    active_fip_mentoring_ero: "active_fip_mentoring_ero",
    active_fip_mentoring: "active_fip_mentoring",
    not_yet_mentoring_fip_no_partner: "not_yet_mentoring_fip_no_partner",
    not_yet_mentoring_fip_ero: "not_yet_mentoring_fip_ero",
    not_yet_mentoring_fip: "not_yet_mentoring_fip",
    active_cip_mentoring_no_partner: "active_cip_mentoring_no_partner",
    active_cip_mentoring_ero: "active_cip_mentoring_ero",
    active_cip_mentoring: "active_cip_mentoring",
    not_yet_mentoring_cip_no_partner: "not_yet_mentoring_cip_no_partner",
    not_yet_mentoring_cip_ero: "not_yet_mentoring_cip_ero",
    not_yet_mentoring_cip: "not_yet_mentoring_cip",
    registered_for_fip_no_partner: "registered_for_fip_no_partner",
    registered_for_fip_training: "registered_for_fip_training",
    active_fip_training: "active_fip_training",
    registered_for_cip_training: "registered_for_cip_training",
    active_cip_training: "active_cip_training",
    active_diy_training: "active_diy_training",
  }, _prefix: "is"

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
  end

  def self.for(participant_profile:, induction_record: nil, delivery_partner: nil, school: nil)
    if school.present?
      where(participant_profile:, school_id: school.id)
    elsif delivery_partner.present?
      where(participant_profile:, delivery_partner_id: delivery_partner.id)
    elsif induction_record.present?
      where(participant_profile:, induction_record_id: induction_record.id)
    else
      where(participant_profile:)
    end
  end

  def self.latest_for(participant_profile:, induction_record: nil, delivery_partner: nil, school: nil)
    self.for(participant_profile:, induction_record:, delivery_partner:, school:).latest
  end

  def self.latest
    order(changed_at: :desc).first
  end

  def readonly?
    true
  end
end
