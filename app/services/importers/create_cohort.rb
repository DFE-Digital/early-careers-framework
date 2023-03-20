# frozen_string_literal: true

module Importers
  class CreateCohort < BaseService
    def call
      check_headers!

      logger.info "CreateCohort: Started!"
      rows.each do |row|
        create_cohort(row)
      end
      logger.info "CreateCohort: Finished!"
    end

  private

    attr_reader :path_to_csv, :logger

    def initialize(path_to_csv:, logger: Rails.logger)
      @path_to_csv = path_to_csv
      @logger = logger
    end

    def create_cohort(row)
      start_year = row["start-year"].to_i
      logger.info "CreateCohort: Creating cohort for starting year #{start_year}"

      Cohort.find_or_create_by!(start_year:) do |c|
        c.registration_start_date = safe_parse(row["registration-start-date"])
        c.academic_year_start_date = safe_parse(row["academic-year-start-date"])
        c.npq_registration_start_date = safe_parse(row["npq-registration-start-date"])
      end

      logger.info "CreateCohort: Cohort for starting year #{start_year} successfully created"
    end

    def safe_parse(date)
      return if date.blank?

      Date.parse(date)
    rescue Date::Error
      logger.warn "CreateCohort: Error parsing date"
      nil
    end

    def check_headers!
      unless %w[start-year registration-start-date academic-year-start-date npq-registration-start-date].all? { |header| rows.headers.include?(header) }
        raise NameError, "Invalid headers"
      end
    end

    def rows
      @rows ||= CSV.read(path_to_csv, headers: true)
    end
  end
end
