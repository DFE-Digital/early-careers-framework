# frozen_string_literal: true

##
# Determine the +status+ for a participant at a given school based on their QTS record
# information and their latest induction record.
#
# == Parameters
# @param :induction_record [InductionRecord] the latest induction record at the school.
# @param :has_mentees [Boolean] whether the participant is mentoring some ECTs at the school. Default is +false+
# @param :profile [ParticipantProfile::ECF] an optional participant profile associated to the induction record.
#   If not provided, the induction_record.participant_profile will be accessed instead.
#
# == Usage:
# <tt>Participants::StatusAtSchool.call(induction_record: induction_record, has_mentees: true)</tt>
#
class Participants::StatusAtSchool < BaseService
  def initialize(induction_record:, has_mentees: false, profile: nil)
    @has_mentees = has_mentees
    @induction_record = induction_record
    @profile = profile || induction_record&.participant_profile
  end

  def status
    @status ||= compute_status
  end

  alias_method :call, :status

private

  attr_reader :has_mentees, :induction_record, :profile

  delegate :ecf_participant_eligibility,
           :ecf_participant_validation_data,
           to: :profile,
           allow_nil: true

  delegate :active_flags_reason?,
           :different_trn_reason?,
           :exempt_from_induction_reason?,
           :ineligible_status?,
           :manual_check_status?,
           :no_induction_reason?,
           :no_qts_reason?,
           :previous_induction_reason?,
           :previous_participation_reason?,
           to: :ecf_participant_eligibility,
           allow_nil: true

  def compute_status
    return :no_longer_being_trained_sit if withdrawn_from_induction?
    return :no_longer_being_trained_provider if withdrawn_from_training?
    return :check_email_address if email_address_not_deliverable?
    return :contacted_for_info if awaiting_contact_from_participant?
    return :no_trn_provided if no_trn?
    return :pending if active_flags_need_checking?
    return :pending if different_trn?
    return :waiting_for_qts if waiting_for_qts?
    return :no_induction_start_date if no_induction?
    return :statutory_induction_completed if previous_induction_or_participation?
    return :exempt if exempt?
    return :duplicate_profile if duplicate?
    return :failed_induction if active_flags_verified?
    return :not_qualified if not_qualified?
    return :training_deferred if deferred?
    return :training_completed if completed?
    return :leaving_your_school if leaving?
    return :joining_your_school if joining?
    return :not_mentoring if not_mentoring?
    return :mentoring if mentoring?

    :training
  end

  # Status predicates
  def active_flags_need_checking?
    manual_check_status? && active_flags_reason?
  end

  def active_flags_verified?
    ineligible_status? && active_flags_reason?
  end

  def awaiting_contact_from_participant?
    request_for_details_email&.delivered? && ecf_participant_validation_data.nil?
  end

  def completed?
    induction_record&.completed_induction_status?
  end

  def deferred?
    (induction_record || profile)&.training_status_deferred?
  end

  def different_trn?
    manual_check_status? && different_trn_reason?
  end

  def duplicate?
    profile&.duplicate?
  end

  def email_address_not_deliverable?
    request_for_details_email&.failed?
  end

  def exempt?
    ineligible_status? && exempt_from_induction_reason?
  end

  def joining?
    induction_record&.active_induction_status? &&
      induction_record&.start_date&.future? &&
      induction_record&.school_transfer?
  end

  def leaving?
    induction_record&.leaving_induction_status?
  end

  def mentoring?
    profile&.mentor? && has_mentees
  end

  def no_induction?
    manual_check_status? && no_induction_reason?
  end

  def no_trn?
    (induction_record || profile)&.trn.blank?
  end

  def not_mentoring?
    profile&.mentor? && !has_mentees
  end

  def not_qualified?
    profile&.ect? && ineligible_status? && no_qts_reason?
  end

  def previous_induction_or_participation?
    ineligible_status? && (previous_induction_reason? || previous_participation_reason?)
  end

  def request_for_details_email
    return @request_for_details_email if defined?(@request_for_details_email)

    @request_for_details_email = Email.associated_with(profile).tagged_with(:request_for_details).latest
  end

  def waiting_for_qts?
    manual_check_status? && no_qts_reason?
  end

  def withdrawn_from_induction?
    induction_record&.withdrawn_induction_status? || profile&.withdrawn_record?
  end

  def withdrawn_from_training?
    (induction_record || profile)&.training_status_withdrawn?
  end
end
