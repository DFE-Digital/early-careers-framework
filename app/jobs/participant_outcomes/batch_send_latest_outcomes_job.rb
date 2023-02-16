# frozen_string_literal: true

module ParticipantOutcomes
  class BatchSendLatestOutcomesJob < ApplicationJob
    queue_as :participant_outcomes

    DEFAULT_BATCH_SIZE = 200
    REQUEUE_DELAY = 2.minutes

    def perform(batch_size = DEFAULT_BATCH_SIZE)
      return unless can_enqueue_jobs?

      @batch_size = batch_size

      outcomes.first(@batch_size).each { |outcome| SendToQualifiedTeachersApiJob.perform_later(outcome.id) }

      self.class.set(wait: REQUEUE_DELAY).perform_later if should_enqueue_again?
    end

  private

    def outcomes
      @outcomes ||= ParticipantDeclaration::NPQ
        .with_outcomes_not_sent_to_qualified_teachers_api
        .map { |declaration| declaration.outcomes.to_send_to_qualified_teachers_api }
        .flatten
    end

    def can_enqueue_jobs?
      ActiveJob::Base.queue_adapter.enqueued_jobs
        .select { |job| job[:job] == SendToQualifiedTeachersApiJob }
        .empty?
    end

    def should_enqueue_again?
      outcomes.count > @batch_size
    end
  end
end
