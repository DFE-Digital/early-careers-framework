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
        add_ineligible_record!(trn: row["trn"])
      elsif row["name"].present?
        if row["dob"].present? || row["urn"].present?
          add_ineligible_record!(full_name: row["name"], date_of_birth: row["dob"], urn: row["urn"])
        else
          @logger.info "Not enough info to add #{row['name']}"
          invalid_count += 1
        end
      else
        @logger.info "Not adding #{row}"
        invalid_count += 1
      end
      row_count += 1
    end

    @logger.info "Processed #{row_count} - (#{invalid_count} incomplete rows)"
  end

private

  def add_ineligible_record!(attrs)
    ECFIneligibleParticipant.find_or_create_by!(attrs) do |record|
      record.reason = @reason
    end
  end
end
