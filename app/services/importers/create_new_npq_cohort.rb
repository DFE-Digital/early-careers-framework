# frozen_string_literal: true

module Importers
  class CreateNewNPQCohort
    attr_reader :cohort_csv, :schedule_csv, :contract_csv, :statement_csv, :logger

    def initialize(cohort_csv:, schedule_csv:, contract_csv:, statement_csv:, logger: Rails.logger)
      @cohort_csv = cohort_csv
      @schedule_csv = schedule_csv
      @contract_csv = contract_csv
      @statement_csv = statement_csv
      @logger = logger
    end

    def call
      logger.info "Running CreateCohort with: '#{cohort_csv}'"
      CreateCohort.new(path_to_csv: cohort_csv).call

      logger.info "Running CreateSchedule with: '#{schedule_csv}'"
      CreateSchedule.new(path_to_csv: schedule_csv).call

      logger.info "Running CreateNPQContract with: '#{contract_csv}'"
      CreateNPQContract.new(path_to_csv: contract_csv).call

      logger.info "Running CreateStatement with: '#{statement_csv}'"
      CreateStatement.new(path_to_csv: statement_csv).call
    end
  end
end
