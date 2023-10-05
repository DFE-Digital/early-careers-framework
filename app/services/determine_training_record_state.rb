# frozen_string_literal: true

class DetermineTrainingRecordState < BaseService
  attr_reader :induction_records

  def call
    induction_records.map { |induction_record|
      TrainingRecordState.new(induction_record)
    }.index_by(&:participant_profile_id)
  end

private

  def initialize(induction_records:)
    @induction_records = Array.wrap(induction_records)
  end
end
