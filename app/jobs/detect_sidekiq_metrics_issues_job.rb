# frozen_string_literal: true

class DetectSidekiqMetricsIssuesJob
  include Sidekiq::Worker

  SIDEKIQ_QUEUE_NAMES = %w[priority_mailers mailers default participant_outcomes big_query].freeze
  SIDEKIQ_RETRIES_THRESHOLD = 200
  SIDEKIQ_LATENCY_THRESHOLD = 120

  queue_as :slack_alerts

  def perform
    detect_high_sidekiq_retries_queue_length
    detect_high_sidekiq_latency
  end

  def detect_high_sidekiq_retries_queue_length
    retries_queue_length = Sidekiq::RetrySet.new.size

    if retries_queue_length > SIDEKIQ_RETRIES_THRESHOLD
      SidekiqSlackNotificationJob.perform_async("Sidekiq pending retries depth is high (#{retries_queue_length}). Suggests high error rate.")
    end
  end

  def detect_high_sidekiq_latency
    SIDEKIQ_QUEUE_NAMES.each do |queue_name|
      latency = Sidekiq::Queue.new(queue_name).latency

      next unless latency >= SIDEKIQ_LATENCY_THRESHOLD

      SidekiqSlackNotificationJob.perform_async("Sidekiq queue #{queue_name} latency is high (#{latency}).")
    end
  end
end
