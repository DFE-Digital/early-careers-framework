# frozen_string_literal: true

module SitValidateParticipantHelper
  def eligible?(profile)
    profile.ecf_participant_eligibility&.eligible_status?
  end

  def ineligible?(profile)
    profile.ineligible_status?
  end

  def ineligible_mentor_at_additional_school?(profile)
    ineligible?(profile) && mentor_with_duplicate_profile?(profile)
  end

  def ineligible_mentor_in_early_rollout?(profile)
    ineligible?(profile) && mentor_was_in_early_rollout?(profile)
  end

  def mentor_was_in_early_rollout?(profile)
    return unless profile.mentor?

    profile.previous_participation?
  end

  def mentor_with_duplicate_profile?(profile)
    return unless profile.mentor?

    profile.duplicate?
  end

  def exempt_from_induction?(profile)
    profile.ecf_participant_eligibility&.exempt_from_induction_reason?
  end

  def previous_induction?(profile)
    profile.previous_induction?
  end

  def participant_has_no_qts?(profile)
    profile.no_qts?
  end
end
