# frozen_string_literal: true

class SchoolDataImporterJob < ApplicationJob
  def perform
    SchoolDataImporter.new(Rails.logger).run
  end
end
