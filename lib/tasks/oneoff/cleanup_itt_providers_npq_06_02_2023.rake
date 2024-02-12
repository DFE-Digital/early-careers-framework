# frozen_string_literal: true

# lib/tasks/read_csv.rake

require "csv"

# Namespace for tasks related to NPQ applications.
namespace :npq_applications do
  # This task restores the ITT providers for NPQ applications.
  # It reads a CSV file where each row contains an application ID and the corresponding ITT provider name.
  # For each row, it finds the application with the given ID and updates its ITT provider.
  #
  # Usage:
  # Run this task from the command line in your Rails application directory using:
  # `rake npq_applications:restore_itt_providers['/path/to/your/file.csv']`
  #
  # @param file_path [String] the path to the CSV file
  desc "Restore itt providers"
  task :restore_itt_providers, [:file_path] => :environment do |_, args|
    require "csv"
    require "logger"

    logger = Logger.new($stdout)
    file_path = args[:file_path]

    unless file_path && File.exist?(file_path)
      raise ArgumentError, "File not found: #{file_path}"
    end

    csv_data = CSV.read(file_path)
    csv_data.each do |row|
      application_id, itt_provider_name = row

      logger.info("Processing application: #{application_id}")
      application = NPQApplication.find_by(id: application_id)
      if application
        application.update!(itt_provider: itt_provider_name)
        logger.info("Application #{application_id} updated with ITT provider: #{itt_provider_name}")
      else
        logger.warn("Application not found! #{application_id}")
      end
    end
  end
end
