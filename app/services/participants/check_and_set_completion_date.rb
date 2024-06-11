# frozen_string_literal: true

module Participants
  class CheckAndSetCompletionDate < BaseService
    def call
      return unless participant_profile.ect?
      return Induction::Complete.call(participant_profile:, completion_date:) if complete_induction?

      Participants::SyncDQTInductionStartDate.call(start_date, participant_profile)
      record_completion_date_inconsistency if completion_date_inconsistent?
    end

  private

    attr_reader :participant_profile

    def initialize(participant_profile:)
      @participant_profile = participant_profile
    end

    def complete_induction?
      !participant_completion_date && completion_date
    end

    # Get the latest induction period endDate if induction endDate comes with a value.
    # i.e. induction endDate field value presence flags the latest period is actually the last one.
    def completion_date
      @completion_date ||= induction&.fetch("endDate", nil).presence &&
        induction_periods.map { |period| period["endDate"] }.compact.max
    end

    def completion_date_inconsistent?
      participant_completion_date != completion_date
    end

    def induction
      @induction ||= DQT::GetInductionRecord.call(trn: participant_profile.teacher_profile.trn)
    end

    def induction_periods
      @induction_periods ||= Array(induction&.dig("periods"))
    end

    def participant_completion_date
      participant_profile.induction_completion_date
    end

    def record_completion_date_inconsistency
      ParticipantProfileCompletionDateInconsistency.upsert(
        {
          participant_profile_id: participant_profile.id,
          dqt_value: completion_date,
          participant_value: participant_completion_date,
        },
        unique_by: :participant_profile_id,
      )
    end

    # returns the minimum start date of all the induction periods
    def start_date
      @start_date ||= induction_periods.map { |period| period["startDate"] }.compact.min
    end
  end
end
