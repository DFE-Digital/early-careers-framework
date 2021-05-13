# frozen_string_literal: true

class SchoolDataImporterJob < CronJob
  self.cron_expression = "0 0 1 * *"

  queue_as :session_trim

  def perform
    Rails.logger.info "Trimming session store..."

    cutoff_period = ENV.fetch("SESSION_DAYS_TRIM_THRESHOLD", 30).to_i.days.ago

    ActiveRecord::SessionStore::Session
      .where("updated_at < ?", cutoff_period)
      .delete_all
  end
end
