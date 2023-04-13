# frozen_string_literal: true

# noinspection RubyTooManyMethodsInspection, RubyTooManyInstanceVariablesInspection, RubyInstanceMethodNamingConvention
class DetermineTrainingRecordState < BaseService
  def call
    OpenStruct.new({
      validation_state: @validation_state,
      training_eligibility_state: @training_eligibility_state,
      fip_funding_eligibility_state: @fip_funding_eligibility_state,
      training_state: @training_state,
      record_state: @record_state,
    })
  end

  def is_record_state?(state)
    state == @record_state
  end

private

  def initialize(participant_profile:, induction_record: nil, delivery_partner: nil, school: nil)
    unless participant_profile.is_a? ParticipantProfile
      raise ArgumentError, "Expected a ParticipantProfile, got #{participant_profile.class}"
    end

    @participant_profile = participant_profile

    if participant_profile.ecf?
      unless induction_record.nil? || induction_record.is_a?(InductionRecord)
        raise ArgumentError, "Expected an InductionRecord, got #{induction_record.class}"
      end

      unless delivery_partner.nil? || delivery_partner.is_a?(DeliveryPartner)
        raise ArgumentError, "Expected a DeliveryPartner, got #{delivery_partner.class}"
      end

      unless school.nil? || school.is_a?(School)
        raise ArgumentError, "Expected a School, got #{school.class}"
      end

      if delivery_partner.present? && school.present?
        raise InvalidArgumentError "It is not possible to determine a status for both a school and a delivery partner"
      end

      @induction_record = if delivery_partner.present?
                            Induction::FindBy.call(participant_profile:, delivery_partner:)
                          elsif school.present?
                            Induction::FindBy.call(participant_profile:, school:)
                          else
                            induction_record || participant_profile.induction_records.latest
                          end

      @latest_request_for_details = Email.associated_with(participant_profile)
                                         .tagged_with(:request_for_details)
                                         .latest
    end

    @validation_state = validation_state
    @training_eligibility_state = training_eligibility_state
    @fip_funding_eligibility_state = fip_funding_eligibility_state
    @training_state = training_state
    @record_state = record_state
  end

  def record_state
    return @training_state if %i[withdrawn_programme withdrawn_training deferred_training completed_training].include?(@training_state)

    return @validation_state unless @validation_state == :valid
    return @training_eligibility_state unless %i[eligible_for_mentor_training eligible_for_mentor_training_ero eligible_for_induction_training].include?(@training_eligibility_state)

    return @fip_funding_eligibility_state unless on_cip? || %i[eligible_for_mentor_funding eligible_for_fip_funding].include?(@fip_funding_eligibility_state)

    @training_state
  end

  def validation_state
    return :different_trn if manual_check_different_trn?

    # details have been requested from participant
    return :request_for_details_delivered if request_for_details_delivered?
    return :request_for_details_failed if request_for_details_failed?
    return :request_for_details_submitted if request_for_details_submitted?

    return :validation_not_started if awaiting_validation_data?

    return :internal_error if validation_api_failed?
    return :tra_record_not_found unless tra_record_found?

    :valid
  end

  def training_eligibility_state
    return :checks_not_complete if eligibility_not_checked?

    return :active_flags if manual_check_active_flags?
    return :not_allowed if ineligible_active_flags?

    if @participant_profile.mentor?
      return :eligible_for_mentor_training_ero if ineligible_previous_participation?

      return :eligible_for_mentor_training
    end

    # ECTs only
    return :duplicate_profile if ineligible_duplicate_profile?
    return :secondary_profile if secondary_profile?
    return :not_qualified if manual_check_no_qts?

    return :exempt_from_induction if ineligible_exempt_from_induction?
    return :previous_induction if ineligible_previous_induction?
    return :previous_participation if ineligible_previous_participation?

    return :tra_record_not_found unless tra_record_found?

    :eligible_for_induction_training
  end

  def fip_funding_eligibility_state
    return :checks_not_complete if eligibility_not_checked?

    # DfE can override everything
    return :eligible_for_mentor_funding if eligible? && @participant_profile.mentor?
    return :eligible_for_fip_funding if eligible?

    # ECTs and Mentors
    return :active_flags if manual_check_active_flags?
    return :not_allowed if ineligible_active_flags?

    # TODO: only if they have a FIP mentee or are already doing the training and have not been funded before
    return :eligible_for_mentor_funding if @participant_profile.mentor?

    # ECTs only
    return :duplicate_profile if ineligible_duplicate_profile?
    return :secondary_profile if secondary_profile?
    return :no_induction_start if manual_check_no_induction?
    return :not_qualified if manual_check_no_qts?

    return :exempt_from_induction if ineligible_exempt_from_induction?
    return :previous_induction if ineligible_previous_induction?
    return :previous_participation if ineligible_previous_participation?

    return :tra_record_not_found unless tra_record_found?

    :eligible_for_fip_funding
  end

  def training_state
    return :withdrawn_programme if withdrawn_participant?
    return :withdrawn_training if withdrawn_training?

    return :deferred_training if deferred_training?

    return :completed_training if completed_training?

    # TODO: This may be incorrect if it is a historical IR
    return :no_longer_involved if changed_training?

    return :leaving if is_leaving_school?
    return :left if has_left_school?
    return :joining if is_joining_school?

    if @participant_profile.mentor?
      if ineligible_previous_participation?
        return :registered_for_mentor_training_ero_secondary if secondary_profile?
        return :registered_for_mentor_training_ero_duplicate if ineligible_duplicate_profile?

        return :registered_for_mentor_no_partner if on_fip? && no_partnership?

        return :registered_for_mentor_training_ero_primary if primary_profile?

        return :registered_for_mentor_training_ero
      end

      return :registered_for_mentor_training_secondary if secondary_profile?
      return :registered_for_mentor_training_duplicate if ineligible_duplicate_profile?

      return :registered_for_mentor_no_partner if on_fip? && no_partnership?

      return :registered_for_mentor_training_primary if primary_profile?

      return :registered_for_mentor_training
    end

    if on_fip?
      return :registered_for_fip_no_partner if no_partnership?
      return :registered_for_fip_training if manual_check_no_induction?

      return :active_fip_training
    end

    if on_cip?
      return :registered_for_cip_training if manual_check_no_induction?

      return :active_cip_training
    end

    :active_diy_training
  end

  def on_fip?
    relevant_induction_programme&.full_induction_programme?
  end

  def on_cip?
    relevant_induction_programme&.core_induction_programme?
  end

  def primary_profile?
    @participant_profile.primary_profile?
  end

  def secondary_profile?
    @participant_profile.secondary_profile?
  end

  def sparsity_uplift?
    @participant_profile.sparsity_uplift
  end

  def pupil_premium_uplift?
    @participant_profile.pupil_premium_uplift
  end

  def uplift?
    sparsity_uplift? || pupil_premium_uplift?
  end

  def eligibility_not_checked?
    tra_record_found? && @participant_profile.ecf_participant_eligibility.blank?
  end

  def eligible?
    @participant_profile.ecf_participant_eligibility&.eligible_status?
  end

  def eligible_no_qts?
    eligible? && @participant_profile.ecf_participant_eligibility&.no_qts_reason?
  end

  def ineligible?
    @participant_profile.ecf_participant_eligibility&.ineligible_status?
  end

  def ineligible_active_flags?
    ineligible? && @participant_profile.ecf_participant_eligibility&.active_flags_reason?
  end

  def ineligible_exempt_from_induction?
    ineligible? && @participant_profile.ecf_participant_eligibility&.exempt_from_induction_reason?
  end

  def ineligible_duplicate_profile?
    ineligible? && @participant_profile.ecf_participant_eligibility&.duplicate_profile_reason?
  end

  def ineligible_previous_induction?
    ineligible? && @participant_profile.ecf_participant_eligibility&.previous_induction_reason?
  end

  def ineligible_previous_participation?
    ineligible? && @participant_profile.ecf_participant_eligibility&.previous_participation_reason?
  end

  def manual_checks?
    @participant_profile.ecf_participant_eligibility&.manual_check_status?
  end

  def manual_check_active_flags?
    manual_checks? && @participant_profile.ecf_participant_eligibility&.active_flags_reason?
  end

  def manual_check_different_trn?
    manual_checks? && @participant_profile.ecf_participant_eligibility&.different_trn_reason?
  end

  def manual_check_no_induction?
    manual_checks? && @participant_profile.ecf_participant_eligibility&.no_induction_reason?
  end

  def manual_check_no_qts?
    manual_checks? && @participant_profile.ecf_participant_eligibility&.no_qts_reason?
  end

  def awaiting_validation_data?
    @participant_profile.ecf_participant_validation_data.blank?
  end

  def request_for_details_submitted?
    awaiting_validation_data? && @latest_request_for_details&.status == "submitted"
  end

  def request_for_details_failed?
    awaiting_validation_data? && @latest_request_for_details&.failed?
  end

  def request_for_details_delivered?
    awaiting_validation_data? && @latest_request_for_details&.delivered?
  end

  def validation_api_failed?
    @participant_profile.ecf_participant_validation_data&.api_failure || false
  end

  def tra_record_found?
    @participant_profile.teacher_profile&.trn.present?
  end

  def no_partnership?
    relevant_induction_programme&.partnership&.lead_provider.nil?
  end

  def relevant_induction_programme
    @relevant_induction_programme ||= @induction_record&.induction_programme || @participant_profile.school_cohort&.default_induction_programme
  end

  def withdrawn_training?
    @induction_record.present? ? @induction_record.training_status_withdrawn? : @participant_profile.training_status_withdrawn?
  end

  def deferred_training?
    # only use `participant_profile.training_status` if no `induction_record` is present
    @induction_record.present? ? @induction_record.training_status_deferred? : @participant_profile.training_status_deferred?
  end

  def withdrawn_participant?
    # only use `participant_profile.status` if no `induction_record` is present
    @induction_record.present? ? @induction_record.withdrawn_induction_status? : @participant_profile.withdrawn_record?
  end

  def completed_training?
    @induction_record&.completed_induction_status?
  end

  def changed_training?
    @induction_record&.changed_induction_status?
  end

  def is_leaving_school?
    @induction_record&.leaving_induction_status? && @induction_record&.end_date.present? && @induction_record&.end_date&.future?
  end

  def has_left_school?
    @induction_record&.leaving_induction_status? && @induction_record&.end_date.present? && @induction_record&.end_date&.past?
  end

  def is_joining_school?
    @induction_record&.active_induction_status? && @induction_record&.start_date&.future?
  end
end
