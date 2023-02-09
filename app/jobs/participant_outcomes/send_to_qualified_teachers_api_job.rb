# frozen_string_literal: true

module ParticipantOutcomes
  class SendToQualifiedTeachersApiJob < ApplicationJob
    queue_as :participant_outcomes
    retry_on StandardError, attempts: 3

    def perform(_participant_outcome)
      # TODO: needs to be implemented
      "actioned"
    end
  end
end
