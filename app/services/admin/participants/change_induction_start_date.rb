# frozen_string_literal: true

module Admin::Participants
  class ChangeInductionStartDate < BaseService
    attr_reader :participant_profile, :induction_start_date

    def initialize(participant_profile, induction_start_date:)
      @participant_profile = participant_profile
      @induction_start_date = induction_start_date
    end

    def call
      Participants::SyncDQTInductionStartDate.call(induction_start_date, participant_profile)
    end
  end
end
