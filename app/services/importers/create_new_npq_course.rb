# frozen_string_literal: true

module Importers
  class CreateNewNPQCourse
    def call
      logger.info "CreateNewNPQCourse: Started!"
      check_csvs!

      logger.info "Running CreateNPQCourse with: '#{npq_course_csv}'"
      CreateNPQCourse.new(path_to_csv: npq_course_csv).call

      logger.info "Running CreateNPQContract with: '#{contract_csv}'"
      CreateNPQContract.new(path_to_csv: contract_csv, new_course_flag: true).call
    end

  private

    attr_reader :npq_course_csv, :contract_csv, :logger

    def initialize(npq_course_csv:, contract_csv:, logger: Rails.logger)
      @npq_course_csv = npq_course_csv
      @contract_csv = contract_csv
      @logger = logger
    end

    def check_csvs!
      return if npq_course_csv.present? && contract_csv.present?

      raise "All scripts need to be present to create a new ECF cohort"
    end
  end
end
