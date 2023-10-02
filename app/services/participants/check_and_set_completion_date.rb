# frozen_string_literal: true

module Participants
  class CheckAndSetCompletionDate < BaseService
    def call
      return unless participant_profile.ect?
      Induction::Complete.call(participant_profile:, completion_date:) if completion_date.present?
    end

  private
    attr_reader :participant_profile

    def initialize(participant_profile:)
      @participant_profile = participant_profile
    end

    def completion_date
      induction&.fetch("endDate", nil)
    end

    def induction
      @induction ||= DQT::GetInductionRecord.call(trn: participant_profile.teacher_profile.trn)
    end
  end
end
