# frozen_string_literal: true

require "csv"

module Importers
  class ReconcilationDataImporter < BaseService
    def call
      check_headers!

      logger.info "ReconcilationDataImporter: Started!"

      ActiveRecord::Base.transaction do
        rows.each do |row|
          transfer_data(row)
        end
      end

      logger.info "ReconcilationDataImporter: Finished!"
    end

  private

    attr_reader :path_to_csv, :logger

    def initialize(path_to_csv:, logger: Rails.logger)
      @path_to_csv = path_to_csv
      @logger = logger
    end

    def transfer_data(row)
      to_user = User.find_by(id: row["participant_id 1"])
      from_user = User.find_by(id: row["participant_id 2"])
      if from_user.present? && to_user.present?
        Identity::Transfer.call(from_user:, to_user:)
        Rails.logger.info("Data is successfully moved from #{from_user.email} to #{to_user.email}")
      else
        Rails.logger.info("Data is not updated because user data is not present")
      end
    end

    def check_headers!
      unless ["participant_id 1", "participant_id 2"].all? { |header| rows.headers.include?(header) }
        raise NameError, "Invalid headers"
      end
    end

    def rows
      @rows ||= CSV.read(path_to_csv, headers: true)
    end
  end
end
