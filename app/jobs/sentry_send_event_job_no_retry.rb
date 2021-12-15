# frozen_string_literal: true

class SentrySendEventJobNoRetry
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(event, hint)
    Sentry.send_event(event, hint)
  end
end
