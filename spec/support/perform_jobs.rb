# frozen_string_literal: true

require "sidekiq/testing"

RSpec.configure do |config|
  Sidekiq::Testing.fake!

  config.around(:each, perform_jobs: true) do |example|
    Sidekiq::Testing.inline! do
      queue_adapter = ActiveJob::Base.queue_adapter
      old_perform_enqueued_jobs = queue_adapter.perform_enqueued_jobs
      old_perform_enqueued_at_jobs = queue_adapter.perform_enqueued_at_jobs
      old_queue = queue_adapter.queue
      queue_adapter.perform_enqueued_jobs = true
      queue_adapter.perform_enqueued_at_jobs = true
      queue_adapter.queue = begin
        queue_name
      rescue StandardError
        :default
      end
      example.run
    ensure
      queue_adapter.perform_enqueued_jobs = old_perform_enqueued_jobs
      queue_adapter.perform_enqueued_at_jobs = old_perform_enqueued_at_jobs
      queue_adapter.queue = old_queue
    end
  end
end
