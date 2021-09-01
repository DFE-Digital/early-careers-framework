# frozen_string_literal: true

class ImportGiasDataJob < CronJob
  self.cron_expression = "30 6 * * *"

  queue_as :school_data

  def perform
    Rails.logger.info "Importing GIAS data..."
    DataStage::FetchGiasDataFiles.call { |files| DataStage::UpdateStagedSchools.call(files) }
  end
end
