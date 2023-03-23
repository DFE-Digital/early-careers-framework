# frozen_string_literal: true

class SchoolParticipantsStatusTagStatus
  def initialize(participant_profile:, induction_record: nil)
    @participant_profile = participant_profile
    @induction_record = induction_record

    @eligibility = participant_profile.ecf_participant_eligibility
  end

  def record_state
    return awaiting_validation_status if participant_profile.ecf_participant_validation_data.blank?
    return :eligible_cip if core_induction_programme?

    if FeatureFlag.active?(:eligibility_notifications) && eligibility.present?
      return fip_eligible_status if eligibility.eligible_status? || eligibility.duplicate_profile_reason?
      return fip_ineligible_status(eligibility) if eligibility.ineligible_status?
      return fip_manual_check_status(eligibility) if eligibility.manual_check_status?
      return fip_manual_check_status(eligibility) if eligibility.manual_check_status?
    end

    :checking_eligibility
  end

private

  attr_reader :participant_profile, :induction_record, :eligibility

  delegate :school_cohort, to: :participant_profile
  delegate :core_induction_programme?, to: :school_cohort
  delegate :delivery_partner, to: :school_cohort

  def fip_eligible_status
    delivery_partner ? :eligible_fip : :eligible_fip_no_partner
  end

  def fip_manual_check_status(eligibility)
    if eligibility.no_qts_reason?
      participant_profile.ect? ? :fip_ect_no_qts : :checking_eligibility
    else
      :checking_eligibility
    end
  end

  def fip_ineligible_status(eligibility)
    case eligibility.reason
    when "previous_induction"
      :ineligible_previous_induction
    when "previous_participation"
      :ero_mentor
    when "active_flags"
      :ineligible_flag
    else
      :ineligible_generic
    end
  end

  def awaiting_validation_status
    return :details_required if latest_email&.delivered?
    return :request_for_details_failed if latest_email&.failed?

    :request_to_be_sent
  end

  def latest_email
    return @latest_email if defined?(@latest_email)

    @latest_email = Email.associated_with(participant_profile).tagged_with(:request_for_details).latest
  end
end
