# frozen_string_literal: true

class ParticipantStatusTagComponent < BaseComponent
  def initialize(profile:)
    @profile = profile
  end

  def call
    if profile.npq?
      render Admin::Participants::NPQValidationStatusTag.new(profile: profile)
    else
      govuk_tag(**tag_attributes)
    end
  end

private

  attr_reader :profile

  def tag_attributes
    return { text: "Not eligible: NQT+1", colour: "red" } if nqt_plus_one?
    return { text: "Not eligible", colour: "red" } if active_flags? && on_cip?
    return { text: "DfE checking eligibility", colour: "orange" } if profile.manual_check_needed? && on_cip?
    return { text: "Eligible to start: ERO", colour: "green" } if ineligible? && mentor_was_in_early_rollout? && on_fip?
    return { text: "Eligible to start", colour: "green" } if eligible? && (on_cip? || on_fip?)
    return { text: "Not eligible: No QTS", colour: "red" } if participant_has_no_qts?
    return { text: "Contacted for information", colour: "grey" } if latest_email&.delivered?
    return { text: "Check email address", colour: "grey" } if latest_email&.failed?

    { text: "Contacting for information", colour: "grey" }
  end

  def latest_email
    return @latest_email if defined?(@latest_email)

    @latest_email = Email.associated_with(profile).tagged_with(:request_for_details).latest
  end

  def eligible?
    profile&.ecf_participant_eligibility&.eligible_status?
  end

  def ineligible?
    profile&.ecf_participant_eligibility&.ineligible_status?
  end

  def mentor_was_in_early_rollout?
    return unless profile.mentor?

    profile.ecf_participant_eligibility.previous_participation_reason?
  end

  def on_cip?
    profile&.school_cohort&.core_induction_programme?
  end

  def on_fip?
    profile&.school_cohort&.full_induction_programme?
  end

  def nqt_plus_one?
    profile&.ecf_participant_eligibility&.previous_induction_reason?
  end

  def participant_has_no_qts?
    participant_eligibility = ECFParticipantEligibility.find_by(participant_profile: profile)
    participant_eligibility&.no_qts_reason?
  end

  def active_flags?
    profile&.ecf_participant_eligibility&.active_flags_reason?
  end
end
