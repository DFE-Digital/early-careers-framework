# frozen_string_literal: true

module ParticipantOutcomes
  class SendToQualifiedTeachersApiJob < ApplicationJob
    queue_as :participant_outcomes
    retry_on TooManyRequests, attempts: 3

    def perform(participant_outcome_id:)
      QualifiedTeachersApiSender.new(participant_outcome_id:).call
    end
  end
end
