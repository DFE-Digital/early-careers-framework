# frozen_string_literal: true

# noinspection RubyInstanceMethodNamingConvention
class Participants::FindByTrainingRecordState < BaseService
  def call
    TrainingRecordState.refresh

    case @record_state

    when :different_trn
      @base_query = @base_query.merge(ParticipantProfile.record_state_different_trn)

    when :request_for_details_submitted
      @base_query = @base_query.merge(ParticipantProfile.record_state_request_for_details_submitted)

    when :request_for_details_failed
      @base_query = @base_query.merge(ParticipantProfile.record_state_request_for_details_failed)

    when :request_for_details_delivered
      @base_query = @base_query.merge(ParticipantProfile.record_state_request_for_details_delivered)

    when :validation_not_started
      @base_query = @base_query.merge(ParticipantProfile.record_state_validation_not_started)

    when :internal_error
      @base_query = @base_query.merge(ParticipantProfile.record_state_internal_error)

    when :tra_record_not_found
      @base_query = @base_query.merge(ParticipantProfile.record_state_tra_record_not_found)

    when :valid
      @base_query = @base_query.merge(ParticipantProfile.validation_state_valid)

    when :active_flags
      @base_query = @base_query.merge(ParticipantProfile.record_state_active_flags)

    when :not_allowed
      @base_query = @base_query.merge(ParticipantProfile.record_state_not_allowed)

    when :eligible_for_mentor_training_ero
      @base_query = @base_query.merge(ParticipantProfile.record_state_eligible_for_mentor_training_ero)

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

  def merge(*filters)
    first_filter = filters.pop
    @base_query = @base_query.merge(first_filter)

    filters.each do |filter|
      @base_query = @base_query.or(filter)
    end
  end
end
