# frozen_string_literal: true

# validation_state:
#   different_trn
#   internal_error
#   request_for_details_delivered
#   request_for_details_failed
#   request_for_details_submitted
#   tra_record_not_found
#   valid
#   validation_not_started
#
# training_eligibility_state:
#   active_flags
#   checks_not_complete
#   duplicate_profile
#   eligible_for_induction_training
#   eligible_for_mentor_training
#   exempt_from_induction
#   not_allowed
#   not_qualified
#   not_yet_mentoring
#   previous_induction
#   tra_record_not_found
#
# fip_funding_eligibility_state:
#   active_flags
#   checks_not_complete
#   duplicate_profile
#   eligible_for_fip_funding
#   eligible_for_mentor_funding
#   eligible_for_mentor_funding_primary
#   exempt_from_induction
#   ineligible_ero
#   ineligible_ero_primary
#   ineligible_ero_secondary
#   ineligible_secondary
#   no_induction_start
#   not_allowed
#   not_qualified
#   previous_induction
#   tra_record_not_found
#
# mentoring_state:
#   active_mentoring
#   active_mentoring_ero
#   not_a_mentor
#   not_yet_mentoring
#   not_yet_mentoring_ero
#
# training_state:
#   active_cip_training
#   active_diy_training
#   active_fip_training
#   completed_training
#   deferred_training
#   joining
#   leaving
#   left
#   no_longer_involved
#   not_registered_for_training
#   registered_for_cip_training
#   registered_for_diy_training
#   registered_for_fip_no_partner
#   registered_for_fip_training
#   withdrawn_programme
#   withdrawn_training
#
# record_state:
#   active_cip_training
#   active_diy_training
#   active_fip_training
#   active_flags
#   active_mentoring
#   active_mentoring_ero
#   checks_not_complete
#   completed_training
#   deferred_training
#   different_trn
#   duplicate_profile
#   exempt_from_induction
#   internal_error
#   joining
#   leaving
#   left
#   no_induction_start
#   no_longer_involved
#   not_allowed
#   not_qualified
#   not_registered_for_training
#   not_yet_mentoring
#   not_yet_mentoring_ero
#   previous_induction
#   registered_for_cip_training
#   registered_for_diy_training
#   registered_for_fip_no_partner
#   registered_for_fip_training
#   request_for_details_delivered
#   request_for_details_failed
#   request_for_details_submitted
#   tra_record_not_found
#   validation_not_started
#   withdrawn_programme
#   withdrawn_training
class TrainingRecordState
  RECORD_STATES = %w[
    different_trn
    request_for_details_delivered
    request_for_details_failed
    request_for_details_submitted
    validation_not_started
    internal_error
    tra_record_not_found
    checks_not_complete
    active_flags
    not_allowed
    duplicate_profile
    not_qualified
    exempt_from_induction
    previous_induction
    no_induction_start
    active_mentoring_ero
    active_mentoring
    not_yet_mentoring_ero
    not_yet_mentoring
    no_longer_involved
    leaving
    left
    joining
    withdrawn_programme
    withdrawn_training
    deferred_training
    completed_training
    registered_for_fip_no_partner
    active_fip_training
    registered_for_fip_training
    registered_for_cip_training
    active_cip_training
    active_diy_training
    registered_for_diy_training
    not_registered_for_training
  ].each_with_object({}) { |v, h| h[v] = v }.freeze

  attr_reader :induction_record, :participant_profile

  delegate :id, to: :participant_profile, prefix: true

  def initialize(participant_profile, induction_record)
    @participant_profile = participant_profile
    @induction_record = induction_record
  end

  def validation_state
    @validation_state ||= begin
      return :different_trn if manual_check_different_trn?

      return :request_for_details_delivered if request_for_details_delivered?
      return :request_for_details_failed if request_for_details_failed?
      return :request_for_details_submitted if request_for_details_submitted?

      return :validation_not_started if awaiting_validation_data?

      return :internal_error if validation_api_failed?
      return :tra_record_not_found if no_tra_record_found?

      :valid
    end
  end

  def training_eligibility_state
    @training_eligibility_state ||= begin
      return :checks_not_complete if eligibility_not_checked?

      return :active_flags if manual_check_active_flags?
      return :not_allowed if ineligible_active_flags?

      return :eligible_for_mentor_training if mentored?
      return :not_yet_mentoring if mentor?

      return :duplicate_profile if ineligible_duplicate_profile?
      return :not_qualified if manual_check_no_qts?

      return :exempt_from_induction if ineligible_exempt_from_induction?
      return :previous_induction if ineligible_previous_induction?

      return :tra_record_not_found if no_tra_record_found?

      :eligible_for_induction_training
    end
  end

  def fip_funding_eligibility_state
    @fip_funding_eligibility_state ||= begin
      return :checks_not_complete if eligibility_not_checked?

      return :eligible_for_fip_funding if eligible? && !mentor?

      unless eligible? && mentor?
        return :active_flags if manual_check_active_flags?
        return :not_allowed if ineligible_active_flags?
      end

      if mentor?
        if ineligible_previous_participation?
          return :ineligible_ero_secondary if secondary_profile? || ineligible_duplicate_profile?
          return :ineligible_ero_primary if primary_profile?

          return :ineligible_ero
        end

        return :ineligible_secondary if secondary_profile? || ineligible_duplicate_profile?
        return :eligible_for_mentor_funding_primary if primary_profile?

        return :eligible_for_mentor_funding
      end

      return :duplicate_profile if ineligible_duplicate_profile?
      return :no_induction_start if manual_check_no_induction?
      return :not_qualified if manual_check_no_qts?

      return :exempt_from_induction if ineligible_exempt_from_induction?
      return :previous_induction if ineligible_previous_induction?

      return :tra_record_not_found if no_tra_record_found?

      :eligible_for_fip_funding
    end
  end

  def training_state
    @training_state ||= begin
      return :no_longer_involved if changed_training?
      return :leaving if is_leaving_school?
      return :left if has_left_school?
      return :joining if is_joining_school?

      return :withdrawn_programme if withdrawn_participant?
      return :withdrawn_training if withdrawn_training?
      return :deferred_training if deferred_training?
      return :completed_training if completed_training?

      ect_training_state
    end
  end

  def mentoring_state
    @mentoring_state ||= begin
      return :not_a_mentor unless mentor?

      if mentoring?
        return :active_mentoring_ero if previous_participation?

        :active_mentoring
      else
        return :not_yet_mentoring_ero if previous_participation?

        :not_yet_mentoring
      end
    end
  end

  def ect_training_state
    @ect_training_state ||= begin
      if on_fip?
        return :registered_for_fip_no_partner if no_partnership?
        return :registered_for_fip_training unless induction_start_date_in_past?

        return :active_fip_training
      end

      if on_cip?
        return :registered_for_cip_training unless induction_start_date_in_past?

        return :active_cip_training
      end

      if on_design_our_own?
        return :registered_for_diy_training unless induction_start_date_in_past?

        return :active_diy_training
      end

      :not_registered_for_training
    end
  end

  def record_state
    @record_state ||= begin
      return training_state if withdrawn_participant? || (transitioning_or_not_currently_training? && !mentor?)
      return validation_state unless validation_status_valid?
      return training_eligibility_state unless eligible_for_training?
      return fip_funding_eligibility_state if on_fip? && !applicable_funding_state?
      return mentoring_state if mentor?

      training_state
    end
  end

  def validation_status_valid?
    validation_state == :valid
  end

private

  def latest_request_for_details
    if induction_record.respond_to?(:transient_latest_request_for_details_status)
      return Email.new(status: induction_record.transient_latest_request_for_details_status)
    end

    @latest_request_for_details ||= Email
      .associated_with(participant_profile)
      .tagged_with(:request_for_details)
      .select(:status)
      .latest
  end

  def mentoring?
    return false unless mentor?
    return induction_record.transient_current_mentees if induction_record.respond_to?(:transient_current_mentees)

    @mentoring ||= InductionRecord.current.where(mentor_profile_id: participant_profile.id).exists?
  end

  def mentored?
    return false unless mentor?
    return induction_record.transient_mentees if induction_record.respond_to?(:transient_mentees)

    @mentored ||= InductionRecord.where(mentor_profile_id: participant_profile.id).exists?
  end

  def transitioning_or_not_currently_training?
    %i[
      withdrawn_training
      deferred_training
      completed_training
      joining
      leaving
      left
    ].include?(training_state)
  end

  def eligible_for_training?
    %i[
      eligible_for_mentor_training
      eligible_for_induction_training
    ].include?(training_eligibility_state)
  end

  def applicable_funding_state?
    %i[
      eligible_for_mentor_funding
      eligible_for_mentor_funding_primary
      eligible_for_fip_funding
      ineligible_secondary
      ineligible_ero
      ineligible_ero_primary
      ineligible_ero_secondary
    ].include?(fip_funding_eligibility_state)
  end

  def on_fip?
    relevant_induction_programme&.full_induction_programme?
  end

  def on_cip?
    relevant_induction_programme&.core_induction_programme?
  end

  def on_design_our_own?
    relevant_induction_programme&.design_our_own?
  end

  def mentor?
    participant_profile.mentor?
  end

  def primary_profile?
    participant_profile.primary_profile?
  end

  def secondary_profile?
    participant_profile.secondary_profile?
  end

  def sparsity_uplift?
    participant_profile.sparsity_uplift
  end

  def pupil_premium_uplift?
    participant_profile.pupil_premium_uplift
  end

  def uplift?
    sparsity_uplift? || pupil_premium_uplift?
  end

  def eligibility_not_checked?
    participant_profile.ecf_participant_eligibility.blank? && (participant_profile.ect? || participant_profile.teacher_profile&.trn.present?)
  end

  def eligible?
    participant_profile.ecf_participant_eligibility&.eligible_status?
  end

  def eligible_no_qts?
    eligible? && participant_profile.ecf_participant_eligibility&.no_qts_reason?
  end

  def ineligible?
    participant_profile.ecf_participant_eligibility&.ineligible_status?
  end

  def ineligible_active_flags?
    ineligible? && participant_profile.ecf_participant_eligibility&.active_flags_reason?
  end

  def ineligible_exempt_from_induction?
    ineligible? && participant_profile.ecf_participant_eligibility&.exempt_from_induction_reason?
  end

  def ineligible_duplicate_profile?
    ineligible? && participant_profile.ecf_participant_eligibility&.duplicate_profile_reason?
  end

  def ineligible_previous_induction?
    ineligible? && participant_profile.ecf_participant_eligibility&.previous_induction_reason?
  end

  def ineligible_previous_participation?
    ineligible? && participant_profile.ecf_participant_eligibility&.previous_participation_reason?
  end

  def previous_participation?
    participant_profile.ecf_participant_eligibility&.previous_participation_reason?
  end

  def manual_checks?
    participant_profile.ecf_participant_eligibility&.manual_check_status?
  end

  def manual_check_active_flags?
    manual_checks? && participant_profile.ecf_participant_eligibility&.active_flags_reason?
  end

  def manual_check_different_trn?
    manual_checks? && participant_profile.ecf_participant_eligibility&.different_trn_reason?
  end

  def manual_check_no_induction?
    manual_checks? && participant_profile.ecf_participant_eligibility&.no_induction_reason?
  end

  def manual_check_no_qts?
    manual_checks? && participant_profile.ecf_participant_eligibility&.no_qts_reason?
  end

  def induction_start_date_in_past?
    participant_profile.induction_start_date&.past?
  end

  def awaiting_validation_data?
    participant_profile.teacher_profile&.trn.nil? && participant_profile.ecf_participant_validation_data.blank?
  end

  def request_for_details_submitted?
    awaiting_validation_data? && latest_request_for_details&.submitted?
  end

  def request_for_details_failed?
    awaiting_validation_data? && latest_request_for_details&.failed?
  end

  def request_for_details_delivered?
    awaiting_validation_data? && latest_request_for_details&.delivered?
  end

  def validation_api_failed?
    participant_profile.ecf_participant_validation_data&.api_failure || false
  end

  def no_tra_record_found?
    return participant_profile.teacher_profile&.trn.nil? unless mentor?

    participant_profile.ecf_participant_validation_data&.trn.present? && participant_profile.teacher_profile&.trn.nil?
  end

  def no_partnership?
    relevant_induction_programme&.partnership&.lead_provider.nil?
  end

  def relevant_induction_programme
    @relevant_induction_programme ||= induction_record&.induction_programme || participant_profile.school_cohort&.default_induction_programme
  end

  def withdrawn_training?
    induction_record.present? ? induction_record.training_status_withdrawn? : participant_profile.training_status_withdrawn?
  end

  def deferred_training?
    induction_record.present? ? induction_record.training_status_deferred? : participant_profile.training_status_deferred?
  end

  def withdrawn_participant?
    induction_record.present? ? induction_record.withdrawn_induction_status? : participant_profile.withdrawn_record?
  end

  def completed_training?
    induction_record&.completed_induction_status?
  end

  def changed_training?
    induction_record&.changed_induction_status?
  end

  def is_leaving_school?
    induction_record&.leaving_induction_status? && induction_record&.end_date&.future?
  end

  def has_left_school?
    induction_record&.leaving_induction_status? && induction_record&.end_date&.past?
  end

  def is_joining_school?
    induction_record&.active_induction_status? && induction_record&.school_transfer && induction_record&.start_date&.future?
  end
end
