# frozen_string_literal: true

# noinspection RubyTooManyMethodsInspection
# noinspection RubyInstanceMethodNamingConvention
class DetermineTrainingRecordState < BaseService
  def call
    OpenStruct.new({
      validation_state:,
      training_eligibility_state:,
      funding_eligibility_state:,
      training_state:,
      record_state:,
    })
  end

private

  def initialize(participant_profile:, induction_record: nil)
    unless participant_profile.is_a? ParticipantProfile
      raise ArgumentError, "Expected a ParticipantProfile, got #{participant_profile.class}"
    end

    unless induction_record.nil? || induction_record.is_a?(InductionRecord)
      raise ArgumentError, "Expected a InductionRecord, got #{induction_record.class}"
    end

    @participant_profile = participant_profile
    if participant_profile.ecf?
      @induction_record = induction_record || participant_profile.induction_records.latest

      @latest_request_for_details = Email.associated_with(participant_profile)
                                         .tagged_with(:request_for_details)
                                         .latest
    end
  end

  def record_state
    return training_state if validation_state == :valid_record && training_eligibility_state == :eligible_to_train && funding_eligibility_state == :eligible_for_ecf_funding
    return funding_eligibility_state if validation_state == :valid_record && training_eligibility_state == :eligible_to_train
    return training_eligibility_state if validation_state == :valid_record

    validation_state
  end

  def training_eligibility_state
    :eligible_to_train
  end

  def funding_eligibility_state
    return ecf_funding_eligibility_state if @participant_profile.ecf?

    # NPQ participants have their own funding rules
    :eligible_for_npq_funding
  end

  def ecf_funding_eligibility_state
    # manual checks or data checks required
    return :needs_active_flags_checking if needs_active_flags_checking?
    return :needs_different_trn_checking if needs_different_trn_checking?
    return :waiting_for_induction_data_from_ab if needs_no_induction_checking?
    return :waiting_for_qts if waiting_for_qts?

    # made ineligible after manual checks completed
    return :ineligible_has_active_flags if ineligible_due_to_active_flags?

    # automatic ineligibility
    return :ineligible_has_duplicate_profile if ineligible_due_to_duplicate_profile?
    return :ineligible_is_exempt_from_induction if ineligible_is_exempt_from_induction?
    return :ineligible_has_previous_induction if ineligible_due_to_previous_induction?
    return :ineligible_has_previous_participation if ineligible_due_to_previous_participation?

    # mentors do not require QTS
    return :eligible_for_mentor_funding_only if eligible_for_mentor_funding_only?

    :eligible_for_ecf_funding
  end

  def validation_state
    # details have been requested from participant
    return :request_for_details_submitted if request_for_details_submitted?
    return :request_for_details_sent if request_for_details_sent?
    return :request_for_details_failed if request_for_details_failed?
    return :request_for_details_delivered if request_for_details_delivered?

    # API failure
    return :validation_api_failed if validation_api_failed?

    # record not found for details provided
    return :tra_record_not_found unless tra_record_found?

    :valid_record
  end

  def training_state
    # withdrawn
    return :has_withdrawn_from_programme if withdrawn_from_programme?
    return :has_withdrawn_from_training if withdrawn_from_training?

    # deferred
    return :has_deferred_their_training if deferred_their_training?

    :is_training
  end

  # def is_fip_participant?
  #   @induction_record&.enrolled_in_fip? || @participant_profile.school_cohort&.full_induction_programme?
  # end

  # def is_cip_participant?
  #   @induction_record&.enrolled_in_cip? || @participant_profile.school_cohort&.core_induction_programme?
  # end

  def eligible_for_ecf_funding?
    @participant_profile.ecf_participant_eligibility&.eligible_status?
  end

  def eligible_for_mentor_funding_only?
    eligible_for_ecf_funding? && @participant_profile.ecf_participant_eligibility&.no_qts_reason?
  end

  def ineligible_for_ecf_funding?
    @participant_profile.ecf_participant_eligibility&.ineligible_status?
  end

  def ineligible_due_to_active_flags?
    ineligible_for_ecf_funding? && @participant_profile.ecf_participant_eligibility&.active_flags_reason?
  end

  def ineligible_is_exempt_from_induction?
    ineligible_for_ecf_funding? && @participant_profile.ecf_participant_eligibility&.exempt_from_induction_reason?
  end

  def ineligible_due_to_duplicate_profile?
    ineligible_for_ecf_funding? && @participant_profile.ecf_participant_eligibility&.duplicate_profile_reason?
  end

  def ineligible_due_to_previous_induction?
    ineligible_for_ecf_funding? && @participant_profile.ecf_participant_eligibility&.previous_induction_reason?
  end

  def ineligible_due_to_previous_participation?
    ineligible_for_ecf_funding? && @participant_profile.ecf_participant_eligibility&.previous_participation_reason?
  end

  def needs_manual_checking?
    @participant_profile.ecf_participant_eligibility&.manual_check_status?
  end

  def needs_active_flags_checking?
    needs_manual_checking? && @participant_profile.ecf_participant_eligibility&.active_flags_reason?
  end

  def needs_different_trn_checking?
    needs_manual_checking? && @participant_profile.ecf_participant_eligibility&.different_trn_reason?
  end

  def needs_no_induction_checking?
    needs_manual_checking? && @participant_profile.ecf_participant_eligibility&.no_induction_reason?
  end

  def waiting_for_qts?
    needs_manual_checking? && @participant_profile.ecf_participant_eligibility&.no_qts_reason?
  end

  def awaiting_validation?
    @participant_profile.ecf_participant_validation_data.blank?
  end

  def request_for_details_sent?
    awaiting_validation? && @participant_profile.request_for_details_sent_at.present? && @latest_request_for_details.present?
  end

  def request_for_details_submitted?
    awaiting_validation? && @latest_request_for_details&.status == "submitted"
  end

  def request_for_details_failed?
    awaiting_validation? && @latest_request_for_details&.failed?
  end

  def request_for_details_delivered?
    awaiting_validation? && @latest_request_for_details&.delivered?
  end

  def validation_api_failed?
    @participant_profile.ecf_participant_validation_data&.api_failure || false
  end

  def tra_record_found?
    @participant_profile.teacher_profile&.trn.present?
  end

  def withdrawn_from_training?
    @induction_record&.training_status_withdrawn? || @participant_profile.training_status_withdrawn?
  end

  def deferred_their_training?
    @induction_record&.training_status_deferred? || @participant_profile.training_status_deferred?
  end

  def withdrawn_from_programme?
    # only use `participant_profile.status` if no `induction_record` is present
    @induction_record.present? ? @induction_record.withdrawn_induction_status? : @participant_profile.withdrawn_record?
  end
end
