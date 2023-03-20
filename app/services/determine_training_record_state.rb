# frozen_string_literal: true

class DetermineTrainingRecordState < BaseService
  def call
    return :withdrawn_from_programme if withdrawn_from_programme?
    return :withdrawn_from_training if withdrawn_from_training?

    return :mentoring if @participant_profile.mentor?

    :training
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
    @induction_record = induction_record || participant_profile.induction_records.latest if participant_profile.ecf?
  end

  def withdrawn_from_training?
    @induction_record&.training_status_withdrawn? || @participant_profile.training_status_withdrawn?
  end

  def withdrawn_from_programme?
    # only use `participant_profile.status` if no `induction_record` is present
    @induction_record.present? ? @induction_record.withdrawn_induction_status? : @participant_profile.withdrawn_record?
  end
end
