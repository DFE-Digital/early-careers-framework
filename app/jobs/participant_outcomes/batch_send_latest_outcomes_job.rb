# frozen_string_literal: true

module ParticipantOutcomes
  class BatchSendLatestOutcomesJob < ApplicationJob
    queue_as :participant_outcomes
    sidekiq_options retry: false

    DEFAULT_BATCH_SIZE = 200
    DEFAULT_REQUEUE_DELAY = 2.minutes

    def perform(batch_size = DEFAULT_BATCH_SIZE, delay = DEFAULT_REQUEUE_DELAY)
      unless can_enqueue_jobs?
        Rails.logger.info "BatchSendLatestOutcomesJob: Unable to proceed due to pending SendToQualifiedTeachersApiJob jobs; re-queueing to try again."
        self.class.set(wait: delay).perform_later(batch_size, delay)
        return
      end

      @batch_size = batch_size

      outcomes.first(@batch_size).each { |outcome| SendToQualifiedTeachersApiJob.perform_later(participant_outcome_id: outcome.id) }

      self.class.set(wait: delay).perform_later(batch_size, delay) if should_enqueue_again?
    end

  private

    def outcomes
      @outcomes ||= ParticipantOutcome::NPQ.to_send_to_qualified_teachers_api
    end

    def can_enqueue_jobs?
      # TODO: An adapter interface would be useful here so that we can use this
      # job in the spec suite without stubbing, and simulate jobs on the queue
      # simply by enqueueing them
      Sidekiq::Queue.new("participant_outcomes")
        .detect { |job| job.display_class == "ParticipantOutcomes::SendToQualifiedTeachersApiJob" }
        .nil?
    end

    def should_enqueue_again?
      outcomes.count > @batch_size
    end
  end
end
