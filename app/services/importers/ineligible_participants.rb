# frozen_string_literal: true

class Importers::IneligibleParticipants < BaseService
  attr_reader :path_to_csv

  def initialize(path_to_csv:, reason:, logger: Rails.logger)
    @path_to_csv = path_to_csv
    @reason = reason
    @logger = logger
  end

  def call
    row_count = 0
    invalid_count = 0

    CSV.foreach(@path_to_csv, headers: true) do |row|
      if row["trn"].present?
        ECFIneligibleParticipant.find_or_create_by!(trn: row["trn"]) do |record|
          record.reason = @reason
        end
      else
        @logger.info "Skipping row <#{row}> ..."
        invalid_count += 1
      end
      row_count += 1
    end

    @logger.info "Processed #{row_count} - (#{invalid_count} invalid rows)"
  end
end
