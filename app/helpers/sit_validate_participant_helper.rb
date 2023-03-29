# frozen_string_literal: true

module SitValidateParticipantHelper
  def eligible?(profile)
    profile.eligible?
  end

  def ineligible?(profile)
    profile.ineligible?
  end

  def ineligible_mentor_at_additional_school?(profile)
    ineligible?(profile) && mentor_with_duplicate_profile?(profile)
  end

  def ineligible_mentor_in_early_rollout?(profile)
    ineligible?(profile) && mentor_was_in_early_rollout?(profile)
  end

  def mentor_was_in_early_rollout?(profile)
    return false unless profile.mentor?

    profile.previous_participation?
  end

  def mentor_with_duplicate_profile?(profile)
    return false unless profile.mentor?

    profile.duplicate?
  end

  def exempt_from_induction?(profile)
    !!profile.ecf_participant_eligibility&.exempt_from_induction_reason?
  end

  def previous_induction?(profile)
    profile.previous_induction?
  end

  def participant_has_no_qts?(profile)
    profile.no_qts?
  end

  def eligibility_confirmation_view_for(profile)
    if profile.fundable? || ineligible_mentor_at_additional_school?(profile)
      "schools/add_participants/eligibility_confirmation/eligible"
    elsif profile.manual_check_needed?
      "schools/add_participants/eligibility_confirmation/manual_check_needed"
    elsif profile.previous_induction?
      "schools/add_participants/eligibility_confirmation/previous_induction"
    elsif ineligible_mentor_in_early_rollout?(profile)
      "schools/add_participants/eligibility_confirmation/eligible_ero"
    elsif profile.no_qts?
      "schools/add_participants/eligibility_confirmation/no_qts_reason"
    elsif profile.ineligible?
      "schools/add_participants/eligibility_confirmation/ineligible"
    end
  end
end
