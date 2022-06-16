# frozen_string_literal: true

class ImportGiasDataJob < ApplicationJob
  def perform
    Rails.logger.info "Importing GIAS data..."
    DataStage::FetchGiasDataFiles.call { |files| DataStage::UpdateStagedSchools.call(**files) }
  end
end
