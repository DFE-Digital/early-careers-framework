# frozen_string_literal: true

module Importers
  class CreateNewECFCohort
    def call
      logger.info "CreateNewECFCohort: Started!"
      check_csvs!

      run_ecf_cohort_scripts
      logger.info "CreateNewECFCohort: Finished!"
    end

  private

    attr_reader :cohort_csv, :cohort_lead_provider_csv, :contract_csv, :schedule_csv, :statement_csv, :logger

    def initialize(cohort_csv:, cohort_lead_provider_csv:, contract_csv:, schedule_csv:, statement_csv:, logger: Rails.logger)
      @cohort_csv = cohort_csv
      @cohort_lead_provider_csv = cohort_lead_provider_csv
      @contract_csv = contract_csv
      @schedule_csv = schedule_csv
      @statement_csv = statement_csv
      @logger = logger
    end

    def check_csvs!
      return if cohort_csv.present? && cohort_lead_provider_csv.present? && contract_csv.present? && schedule_csv.present? && statement_csv.present?

      raise "All scripts need to be present to create a new ECF cohort"
    end

    def run_ecf_cohort_scripts
      logger.info "CreateNewECFCohort: Running CreateCohort with: '#{cohort_csv}'"
      CreateCohort.new(path_to_csv: cohort_csv).call

      logger.info "CreateNewECFCohort: Running AddCohortToLeadProvider with: '#{cohort_lead_provider_csv}'"
      AddCohortToLeadProvider.new(path_to_csv: cohort_lead_provider_csv).call

      logger.info "CreateNewECFCohort: Running CreateCallOffContract with: '#{contract_csv}'"
      CreateCallOffContract.new(path_to_csv: contract_csv).call

      logger.info "CreateNewECFCohort: Running CreateSchedule with: '#{schedule_csv}'"
      CreateSchedule.new(path_to_csv: schedule_csv).call

      logger.info "CreateNewECFCohort: Running CreateStatement with: '#{statement_csv}'"
      CreateStatement.new(path_to_csv: statement_csv).call
    end
  end
end
