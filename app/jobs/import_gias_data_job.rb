# frozen_string_literal: true

class ImportGiasDataJob < ApplicationJob
  def perform
    Rails.logger.info "Importing GIAS data..."
    DataStage::FetchGiasDataFiles.call do |files|
      DataStage::UpdateStagedSchools.call(school_data_file: files[:school_data_file], school_links_file: files[:school_links_file])
    end

    Rails.logger.info "Applying GIAS updates..."
    DataStage::ProcessSchoolChanges.call
  end
end
