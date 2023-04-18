# frozen_string_literal: true

# noinspection RubyInstanceMethodNamingConvention
class Participants::FindByTrainingRecordState < BaseService
  def call
    case @record_state

    when :different_trn
      merge(include_different_trn)

    when :request_for_details_submitted
      merge(include_request_for_details_submitted)

    when :request_for_details_failed
      merge(include_request_for_details_failed)

    when :request_for_details_delivered
      merge(include_request_for_details_delivered)

    when :validation_not_started
      merge(include_validation_not_started)

    when :internal_error
      merge(include_internal_error)

    when :tra_record_not_found
      merge(include_tra_record_not_found)

    when :valid
      merge(include_valid)

    when :active_flags
      merge(include_active_flags)

    else
      raise "unknown record state: #{@record_state}"

    end

    @base_query
  end

private

  attr_reader :base_query, :record_state

  def initialize(base_query, record_state)
    @base_query = base_query
    @record_state = record_state
  end

  def merge(filter)
    @base_query = @base_query.merge(filter)
  end

  def include_request_for_details_submitted
    include_request_for_details_email(%w[submitted])
  end

  def include_request_for_details_failed
    include_request_for_details_email(%w[permanent-failure temporary-failure technical-failure])
  end

  def include_request_for_details_delivered
    include_request_for_details_email(%w[delivered])
  end

  def include_request_for_details_email(status)
    emailed_participants =
      Email::Association.joins(:email)
                        .where(emails: { status: }, object_type: "ParticipantProfile")
                        .where("? = ANY (emails.tags)", %w[request_for_details])
                        .pluck(:object_id)

    ParticipantProfile.left_joins(
      :ecf_participant_validation_data,
      :teacher_profile,
      :ecf_participant_eligibility,
    )
    .where.missing(:ecf_participant_validation_data, :ecf_participant_eligibility)
    .where(id: emailed_participants)
  end

  def include_validation_not_started
    emailed_participants =
      Email::Association.joins(:email)
                        .where(object_type: "ParticipantProfile")
                        .where("? = ANY (emails.tags)", %w[request_for_details])
                        .pluck(:object_id)

    ParticipantProfile.left_joins(
      :ecf_participant_validation_data,
      :teacher_profile,
      :ecf_participant_eligibility,
    )
    .where.missing(:ecf_participant_validation_data, :ecf_participant_eligibility)
    .where.not(id: emailed_participants)
  end

  def include_internal_error
    ParticipantProfile.left_joins(
      :ecf_participant_validation_data,
      :teacher_profile,
      :ecf_participant_eligibility,
    )
    .where.missing(:ecf_participant_eligibility)
    .where(match_validation_api_failed)
  end

  def include_tra_record_not_found
    ParticipantProfile.left_joins(
      :ecf_participant_validation_data,
      :teacher_profile,
      :ecf_participant_eligibility,
    )
    .where.missing(:ecf_participant_eligibility)
    .where(match_validation_api_success)
    .where(match_no_trn)
  end

  def include_different_trn
    ParticipantProfile.left_joins(
      :ecf_participant_validation_data,
      :teacher_profile,
      :ecf_participant_eligibility,
    )
    .where(match_manual_check_different_trn)
  end

  def include_valid
    ParticipantProfile.left_joins(
      :ecf_participant_validation_data,
      :teacher_profile,
      :ecf_participant_eligibility,
    )
    .where.not(match_manual_check_different_trn)
    .where.not(match_no_trn)
  end

  def include_active_flags
    ParticipantProfile.left_joins(
      :ecf_participant_validation_data,
      :teacher_profile,
      :ecf_participant_eligibility,
    )
      .where(match_manual_check_active_flags)
  end

  # matchers

  def match_no_trn
    { teacher_profile: { trn: nil } }
  end

  def match_validation_api_success
    { ecf_participant_validation_data: { api_failure: false } }
  end

  def match_validation_api_failed
    { ecf_participant_validation_data: { api_failure: true } }
  end

  def match_manual_check_different_trn
    { ecf_participant_eligibility: { status: "manual_check", reason: "different_trn" } }
  end

  def match_manual_check_active_flags
    { ecf_participant_eligibility: { status: "manual_check", reason: "active_flags" } }
  end
end
