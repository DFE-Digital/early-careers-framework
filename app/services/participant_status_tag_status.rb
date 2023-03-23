# frozen_string_literal: true

class ParticipantStatusTagStatus
  def initialize(participant_profile:, induction_record: nil)
    @participant_profile = participant_profile
    @induction_record = induction_record
  end

  def record_state
    return :withdrawn_training if training_status_withdrawn?
    return :registered_for_fip_training if eligible? && participant_profile.single_profile? && on_fip?
    return :registered_for_cip_training if eligible? && participant_profile.single_profile? # && on_cip?
    return :registered_for_mentor_training if eligible? && participant_profile.primary_profile?
    return :registered_for_mentor_training_second_school if ineligible? && mentor_with_duplicate_profile?

    return :not_qualified if participant_has_no_qts?
    return :manual_check if participant_profile.manual_check_needed?
    return :previous_induction if nqt_plus_one? && ineligible?
    return :previous_participation_ero if ineligible? && mentor_was_in_early_rollout? && on_fip?
    return :previous_participation if ineligible? && mentor_was_in_early_rollout?
    return :ineligible if ineligible?
    return :request_for_details_delivered if latest_email&.delivered?
    return :request_for_details_failed if latest_email&.failed?

    :checks_not_complete
  end

private

  attr_reader :participant_profile, :induction_record

  def training_status_withdrawn?
    (induction_record || participant_profile).training_status_withdrawn?
  end

  def latest_email
    return @latest_email if defined?(@latest_email)

    @latest_email = Email.associated_with(participant_profile).tagged_with(:request_for_details).latest
  end

  def eligible?
    participant_profile.eligible?
  end

  def ineligible?
    participant_profile&.ineligible?
  end

  def mentor_was_in_early_rollout?
    return unless participant_profile.mentor?

    participant_profile.previous_participation?
  end

  def mentor_with_duplicate_profile?
    return unless participant_profile.mentor?

    participant_profile.duplicate?
  end

  def on_fip?
    induction_record&.enrolled_in_fip? || participant_profile&.school_cohort&.full_induction_programme?
  end

  def on_cip?
    induction_record&.enrolled_in_cip? || participant_profile&.school_cohort&.core_induction_programme?
  end

  def nqt_plus_one?
    participant_profile.previous_induction?
  end

  def participant_has_no_qts?
    participant_profile.no_qts?
  end
end
