# frozen_string_literal: true

module ParticipantOutcomes
  class SendToQualifiedTeachersApiJob < ApplicationJob
    queue_as :participant_outcomes
    retry_on StandardError, attempts: 3

    def perform(_participant_outcome_id)
      # TODO: needs to be implemented
      # participant_outcome = ParticipantOutcome::NPQ.find(participant_outcome_id)
      # participant_outcome.update_attributes(:sent_to_qualified_teachers_api_at, Time.zone.now)
      "actioned"
    end
  end
end
