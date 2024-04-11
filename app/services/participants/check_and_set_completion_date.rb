# frozen_string_literal: true

module Participants
  class CheckAndSetCompletionDate < BaseService
    def call
      return unless participant_profile.ect?

      Induction::Complete.call(participant_profile:, completion_date:) if completion_date.present?
      record_start_date_inconsistency if start_date != participant_start_date
    end

  private

    attr_reader :participant_profile

    def initialize(participant_profile:)
      @participant_profile = participant_profile
    end

    def completion_date
      induction&.fetch("endDate", nil)
    end

    def start_date
      induction&.fetch("startDate", nil)
    end

    def participant_start_date
      participant_profile.induction_start_date
    end

    def induction
      @induction ||= DQT::GetInductionRecord.call(trn: participant_profile.teacher_profile.trn)
    end

    def record_start_date_inconsistency
      ParticipantProfileStartDateInconsistency.upsert(
        {
          participant_profile_id: participant_profile.id,
          dqt_value: start_date,
          participant_value: participant_start_date,
        },
      )
    end
  end
end
