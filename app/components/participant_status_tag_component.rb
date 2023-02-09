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
    if training_status_withdrawn?
      { text: "Withdrawn by provider", colour: "red" }
    elsif eligible? && profile.single_profile?
      { text: "Eligible to start", colour: "green" }
    elsif eligible? && profile.primary_profile?
      { text: "Eligible: Mentor at main school", colour: "green" }
    elsif ineligible? && mentor_with_duplicate_profile?
      { text: "Eligible: Mentor at additional school", colour: "green" }

    elsif participant_has_no_qts?
      { text: "Not eligible: No QTS", colour: "red" }
    elsif profile.manual_check_needed?
      { text: "DfE checking eligibility", colour: "orange" }
    elsif nqt_plus_one? && ineligible?
      { text: "Not eligible: NQT+1", colour: "red" }
    elsif ineligible? && mentor_was_in_early_rollout? && on_fip?
      {
        text: "Eligible to start: ERO",
        colour: "green",
        html_attributes: {
          title: "Completed ECF training and are eligible to mentor an ECT but not eligible for further funded training",
        },
      }
    elsif ineligible? && mentor_was_in_early_rollout?
      { text: "Eligible to start", colour: "green" }
    elsif ineligible?
      { text: "Not eligible", colour: "red" }
    elsif latest_email&.delivered?
      { text: "Contacted for information", colour: "grey" }
    elsif latest_email&.failed?
      { text: "Check email address", colour: "grey" }
    else
      { text: "Contacting for information", colour: "grey" }
    end
  end

  def training_status_withdrawn?
    (induction_record || profile).training_status_withdrawn?
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

    profile.ecf_participant_eligibility&.previous_participation_reason?
  end

  def mentor_with_duplicate_profile?
    return unless profile.mentor?

    profile.ecf_participant_eligibility&.duplicate_profile_reason?
  end

  def on_fip?
    induction_record&.enrolled_in_fip? || profile&.school_cohort&.full_induction_programme?
  end

  def nqt_plus_one?
    profile&.ecf_participant_eligibility&.previous_induction_reason?
  end

  def participant_has_no_qts?
    profile.ecf_participant_eligibility&.no_qts_reason?
  end
end
