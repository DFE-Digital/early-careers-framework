# frozen_string_literal: true

class SchoolEmailUpdateJob < CronJob
  self.cron_expression = "30 6 * * *"

  queue_as :update_emails

  def perform
    Rails.logger.info "Updating school emails from GIAS..."
    SchoolDataImporter.new(logger: Rails.logger).update_emails
  end
end
