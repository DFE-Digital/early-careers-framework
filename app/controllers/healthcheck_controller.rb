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
        migration_version: migration_version,
      },
      delayed_job: {
        job_count: delayed_jobs,
        errors: jobs_with_errors,
        failed: failed_jobs,
        last_failure: last_job_failure,
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

  def delayed_jobs
    Delayed::Job.count
  rescue StandardError
    I18n.t(:fail)
  end

  def jobs_with_errors
    Delayed::Job.where.not(last_error: nil).count
  rescue StandardError
    I18n.t(:fail)
  end

  def failed_jobs
    Delayed::Job.where.not(failed_at: nil).count
  rescue StandardError
    I18n.t(:fail)
  end

  def last_job_failure
    Delayed::Job.order(failed_at: :desc).first&.failed_at
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
