# frozen_string_literal: true

module ParticipantOutcomes
  class BatchSendLatestOutcomesJob < ApplicationJob
    queue_as :participant_outcomes
    sidekiq_options retry: false

    DEFAULT_BATCH_SIZE = 200

    def perform(batch_size = DEFAULT_BATCH_SIZE)
      outcomes.first(batch_size).each { |outcome| SendToQualifiedTeachersApiJob.perform_later(participant_outcome_id: outcome.id) }
    end

  private

    def outcomes
      @outcomes ||= ParticipantOutcome::NPQ.to_send_to_qualified_teachers_api
    end
  end
end
