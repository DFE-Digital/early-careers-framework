# frozen_string_literal: true

module ParticipantOutcomes
  class BatchSendLatestOutcomesJob < ApplicationJob
    queue_as :participant_outcomes
    retry_on StandardError, attempts: 3

    BATCH_SIZE = 200
    REQUEUE_DELAY = 2.minutes

    def perform
      return unless can_enqueue_jobs?

      outcomes.each { |outcome| SendToQualifiedTeachersApiJob.perform_later(outcome.id) }

      set(wait_until: REQUEUE_DELAY.from_now).perform_later
    end

  private

    def outcomes
      ParticipantDeclaration::NPQ
        .with_outcomes_not_sent_to_qualified_teachers_api
        .limit(BATCH_SIZE)
        .map { |declaration| declaration.outcomes.to_send_to_qualified_teachers_api }
        .flatten
    end

    def can_enqueue_jobs?
      ActiveJob::Base.queue_adapter.enqueued_jobs
        .select { |job| job[:job] == SendToQualifiedTeachersApiJob }
        .empty?
    end
  end
end
