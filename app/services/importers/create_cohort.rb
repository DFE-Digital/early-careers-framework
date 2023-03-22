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
      create_next_cohort

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

    def create_next_cohort
      latest_cohort = Cohort.order(start_year: :desc).first

      return if latest_cohort.blank?

      academic_year_start_month = latest_cohort.academic_year_start_date.month
      next_cohort_start_year = Date.current.year + (Date.current.month < academic_year_start_month ? 0 : 1)
      if next_cohort_start_year > latest_cohort.start_year
        (latest_cohort.start_year..next_cohort_start_year).drop(1).to_a.each do |start_year|
          logger.info "CreateCohort: Creating next cohort for starting year #{start_year}"

          Cohort.find_or_create_by!(start_year:) do |c|
            c.registration_start_date = latest_cohort.registration_start_date + 1.year if latest_cohort.registration_start_date
            c.academic_year_start_date = latest_cohort.academic_year_start_date + 1.year if latest_cohort.academic_year_start_date
            c.npq_registration_start_date = latest_cohort.npq_registration_start_date + 1.year if latest_cohort.npq_registration_start_date
          end

          logger.info "CreateCohort: Next cohort for starting year #{start_year} successfully created"
        end
      end
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
