# frozen_string_literal: true

class SchoolDataImporterJob < CronJob
  self.cron_expression = "0 6 * * *"

  queue_as :school_data

  def perform
    Rails.logger.info "Importing school data..."
    SchoolDataImporter.new(logger: Rails.logger).run
  end
end
