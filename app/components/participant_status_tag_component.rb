# frozen_string_literal: true

class ParticipantStatusTagComponent < BaseComponent
  def initialize(profile:, induction_record: nil)
    @profile = profile
    @induction_record = induction_record
  end

  def call
    if profile.npq?
      render Admin::Participants::NPQValidationStatusTag.new(profile:)
    else
      govuk_tag(**tag_attributes)
    end
  end

  private

  attr_reader :profile, :induction_record

  def tag_attributes
    # withdrawn trumps everything
    return { text: "No longer being trained", colour: "grey" } if participant_withdrawn?
    return { text: "No longer being trained", colour: "grey" } if participant_withdrawn_from_training?

    # pre-registration checks for manual validation
    return { text: "Check email address", colour: "blue" } if email_address_not_deliverable?
    return { text: "Contacted for information", colour: "grey" } if awaiting_contact_from_participant?

    # Initial TRA record checks
    return { text: "No TRN provided", colour: "blue" } if has_no_trn?
    return { text: "Pending", colour: "blue" } if active_flags_need_checking?
    return { text: "Pending", colour: "blue" } if has_different_trn?

    # Provisional eligibility
    return { text: "Waiting for QTS", colour: "grey" } if waiting_for_qts?
    return { text: "No induction start date", colour: "blue" } if has_no_induction?

    # Not eligible TODO: if the induction is not complete then show "Joining your school" , colour: "blue"
    return { text: "Statutory induction completed", colour: "grey" } if previous_induction_or_participation?
    return { text: "Exempt", colour: "grey" } if exempt_from_induction?
    return { text: "Duplicate profile", colour: "blue" } if duplicate_profile?
    return { text: "No longer being trained", colour: "grey" } if active_flags_verified?
    return { text: "Not qualified", colour: "grey" } if ect_not_qualified?

    # Eligible and no longer participating // skip for mentors
    return { text: "Training deferred", colour: "grey" } if training_status_deferred?
    return { text: "Training completed", colour: "grey" } if participant_completed?


    # return { text: "Leaving your school", colour: "grey" } if participant_leaving? # check date on IR
    return { text: "No longer being trained", colour: "grey" } if participant_leaving?
    # return { text: "Joining your school", colour: "grey" } if participant_leaving? # check date on IR

    # TODO: if number of ECTs < 1 then "Not Mentoring", colour: "blue"
    return { text: "Mentoring", colour: "green" } if profile&.mentor?

    { text: "Training", colour: "green" }
  end

  def participant_withdrawn?
    induction_record&.withdrawn_induction_status? || profile&.withdrawn_record?
  end

  def participant_leaving?
    induction_record&.leaving_induction_status?
  end

  def participant_completed?
    induction_record&.completed_induction_status?
  end

  def participant_withdrawn_from_training?
    (induction_record || profile)&.training_status_withdrawn?
  end

  def training_status_deferred?
    (induction_record || profile)&.training_status_deferred?
  end

  def email_address_not_deliverable?
    request_for_details_email&.failed?
  end

  def awaiting_contact_from_participant?
    request_for_details_email&.delivered? && profile&.ecf_participant_validation_data.nil?
  end

  def request_for_details_email
    return @latest_email if defined?(@latest_email)

    @latest_email = Email.associated_with(profile).tagged_with(:request_for_details).latest
  end

  def has_no_trn?
    profile&.teacher_profile&.trn.blank?
  end

  def active_flags_need_checking?
    eligibility = profile&.ecf_participant_eligibility
    eligibility&.manual_check_status? && eligibility.active_flags_reason?
  end

  def active_flags_verified?
    eligibility = profile&.ecf_participant_eligibility
    eligibility&.ineligible_status? && eligibility.active_flags_reason?
  end

  def has_different_trn?
    eligibility = profile&.ecf_participant_eligibility
    eligibility&.manual_check_status? && eligibility.different_trn_reason?
  end

  def waiting_for_qts?
    eligibility = profile&.ecf_participant_eligibility
    eligibility&.manual_check_status? && eligibility.no_qts_reason?
  end

  def ect_not_qualified?
    eligibility = profile&.ecf_participant_eligibility
    profile&.ect? && eligibility&.ineligible_status? && eligibility.no_qts_reason?
  end

  def has_no_qts?
    profile&.no_qts?
  end

  def has_no_induction?
    eligibility = profile&.ecf_participant_eligibility
    eligibility&.manual_check_status? && eligibility.no_induction_reason?
  end

  def previous_induction_or_participation?
    eligibility = profile&.ecf_participant_eligibility
    eligibility&.ineligible_status? && (eligibility.previous_induction_reason? || eligibility.previous_participation_reason?)
  end

  def exempt_from_induction?
    eligibility = profile&.ecf_participant_eligibility
    eligibility&.ineligible_status? && eligibility.exempt_from_induction_reason?
  end

  def duplicate_profile?
    profile.duplicate?
  end

  def eligible?
    profile.eligible?
  end

  def ineligible?
    profile&.ineligible?
  end

  def mentor_was_in_early_rollout?
    return unless profile.mentor?

    profile.previous_participation?
  end

  def mentor_with_duplicate_profile?
    return unless profile.mentor?

    profile.duplicate?
  end

  def on_fip?
    induction_record&.enrolled_in_fip? || profile&.school_cohort&.full_induction_programme?
  end

  def nqt_plus_one?
    profile.previous_induction?
  end
end
