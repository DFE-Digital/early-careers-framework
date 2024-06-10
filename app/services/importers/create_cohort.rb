# frozen_string_literal: true

require "csv"

module Importers
  class CreateCohort < BaseService
    def call
      check_headers!

      logger.info "CreateCohort: Started!"

      ActiveRecord::Base.transaction do
        rows.each do |row|
          create_cohort(row)
        end
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

      default_automatic_assignment_period_end_date = Date.new(start_year + 1, 3, 31)

      Cohort.upsert(
        {
          start_year:,
          registration_start_date: safe_parse(row["registration-start-date"]),
          academic_year_start_date: safe_parse(row["academic-year-start-date"]),
          npq_registration_start_date: safe_parse(row["npq-registration-start-date"]),
          automatic_assignment_period_end_date: safe_parse(row["automatic-assignment-period-end-date"]) || default_automatic_assignment_period_end_date,
          payments_frozen_at: safe_parse(row["payments-frozen-at"]).presence,
          created_at: Time.zone.now,
          updated_at: Time.zone.now,
        },
        unique_by: :start_year,
      )

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
      unless %w[start-year registration-start-date academic-year-start-date npq-registration-start-date automatic-assignment-period-end-date payments-frozen-at].all? { |header| rows.headers.include?(header) }
        raise NameError, "Invalid headers"
      end
    end

    def rows
      @rows ||= CSV.read(path_to_csv, headers: true)
    end
  end
end
