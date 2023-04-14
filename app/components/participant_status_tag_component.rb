# frozen_string_literal: true

class ParticipantStatusTagComponent < BaseComponent
  def initialize(profile:, induction_record: nil, has_mentees: false)
    @profile = profile
    @induction_record = induction_record
    @has_mentees = has_mentees
  end

  def call
    if profile.npq?
      render Admin::Participants::NPQValidationStatusTag.new(profile:)
    else
      govuk_tag(**tag_attributes)
    end
  end

private

  attr_reader :profile, :induction_record, :has_mentees

  def status
    @status ||= ::Participants::StatusAtSchool.new(induction_record:, has_mentees:, profile:).call
  end

  def tag_attributes
    if FeatureFlag.active?(:cohortless_dashboard)
      {
        text: t(:header, scope: translation_scope),
        colour: t(:colour, scope: translation_scope),
      }
    else
      return { text: "Withdrawn by provider", colour: "red" } if training_status_withdrawn?
      return { text: "Eligible to start", colour: "green" } if eligible? && profile.single_profile?
      return { text: "Eligible: Mentor at main school", colour: "green" } if eligible? && profile.primary_profile?
      return { text: "Eligible: Mentor at additional school", colour: "green" } if ineligible? && mentor_with_duplicate_profile?

      return { text: "Not eligible: No QTS", colour: "red" } if participant_has_no_qts?
      return { text: "DfE checking eligibility", colour: "orange" } if profile.manual_check_needed?
      return { text: "Not eligible: NQT+1", colour: "red" } if nqt_plus_one? && ineligible?
      return { text: "Eligible to start: ERO", colour: "green" } if ineligible? && mentor_was_in_early_rollout? && on_fip?
      return { text: "Eligible to start", colour: "green" } if ineligible? && mentor_was_in_early_rollout?
      return { text: "Not eligible", colour: "red" } if ineligible?
      return { text: "Contacted for information", colour: "grey" } if latest_email&.delivered?
      return { text: "Check email address", colour: "grey" } if latest_email&.failed?

      { text: "Contacting for information", colour: "grey" }
    end
  end

  # Remove this code when we remove FeatureFlag.active?(:cohortless_dashboard) - start #
  def training_status_withdrawn?
    (induction_record || profile).training_status_withdrawn?
  end

  def latest_email
    return @latest_email if defined?(@latest_email)

    @latest_email = Email.associated_with(profile).tagged_with(:request_for_details).latest
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

  def participant_has_no_qts?
    profile.no_qts?
  end
  # Remove this code when we remove FeatureFlag.active?(:cohortless_dashboard) - start

  def translation_scope
    @translation_scope ||= "schools.participants.status.#{status}"
  end
end
