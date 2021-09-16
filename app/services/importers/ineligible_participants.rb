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
        record = ECFIneligibleParticipant.find_or_initialize_by(trn: row["trn"])
        if record.persisted? && record.reason.to_s != @reason.to_s
          @logger.info "Same trn, different reason! #{record.trn}"
          record.reason = :previous_induction_and_participation
        else
          record.reason = @reason
        end
        record.save!
      else
        @logger.info "Skipping row <#{row}> ..."
        invalid_count += 1
      end
      row_count += 1
    end

    @logger.info "Processed #{row_count} - (#{invalid_count} invalid rows)"
  end
end
