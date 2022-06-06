# frozen_string_literal: true

class HealthcheckController < ApplicationController
  NOTIFY_STATUS_API = "https://stdg40247zwv.statuspage.io/api/v2/status.json"

  def check
    render status: :ok, json: {
      version: release_version,
      sha: ENV["SHA"],
      environment: Rails.env,
      database: {
        connected: database_connected?,
        migration_version:,
      },
      sidekiq: {
        job_count: sidekiq_jobs_count,
        errors: sidekiq_jobs_with_errors,
        failed: sidekiq_failures,
        sidekiq_last_failure:,
      },
      notify: {
        incident_status: notify_incident,
      },
      puma: puma_stats,
    }
  end

private

  def database_connected?
    ApplicationRecord.connection.select_value("SELECT 1") == 1
  rescue StandardError
    false
  end

  def migration_version
    ApplicationRecord.connection.migration_context.current_version
  rescue StandardError
    I18n.t(:fail)
  end

  def sidekiq_jobs_count
    Sidekiq::Queue.all.map(&:size).sum
  rescue StandardError
    I18n.t(:fail)
  end

  def sidekiq_jobs_with_errors
    Sidekiq::RetrySet.new.size
  rescue StandardError
    I18n.t(:fail)
  end

  def sidekiq_failures
    Sidekiq::DeadSet.new.size
  rescue StandardError
    I18n.t(:fail)
  end

  def sidekiq_last_failure
    last_failed_at = Sidekiq::DeadSet.new.to_a.max { |j| j["failed_at"] }&.fetch("failed_at")
    return nil unless last_failed_at

    Time.zone.at last_failed_at
  rescue StandardError
    I18n.t(:fail)
  end

  def notify_incident
    status_response = HTTPClient.get(NOTIFY_STATUS_API)
    return I18n.t(:status_request_failed) unless status_response.status == 200

    JSON.parse(status_response.body)["status"]["indicator"]
  rescue StandardError
    I18n.t(:fail)
  end

  def puma_stats
    JSON.parse(Puma.stats)
  rescue StandardError
    I18n.t(:fail)
  end
end
