# frozen_string_literal: true

class DetermineTrainingRecordState < BaseService
  attr_reader :induction_records_by_participant_profile

  def call
    induction_records_by_participant_profile
      .map { |participant_profile, induction_record| TrainingRecordState.new(participant_profile, induction_record) }
      .index_by(&:participant_profile_id)
  end

private

  def initialize(participant_profiles:, induction_records:)
    participant_profiles = Array.wrap(participant_profiles)
    induction_records = Array.wrap(induction_records)

    @induction_records_by_participant_profile = participant_profiles.index_with do |participant_profile|
      induction_records.find { |induction_record| induction_record.participant_profile == participant_profile }
    end
  end
end
