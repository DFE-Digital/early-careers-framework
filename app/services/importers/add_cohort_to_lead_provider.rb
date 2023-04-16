# frozen_string_literal: true

require "csv"

module Importers
  class AddCohortToLeadProvider < BaseService
    def call
      check_headers!

      logger.info "AddCohortToLeadProvider: Started!"

      ActiveRecord::Base.transaction do
        rows.each do |row|
          add_cohort_to_lead_provider(row)
        end
      end

      logger.info "AddCohortToLeadProvider: Finished!"
    end

  private

    attr_reader :path_to_csv, :logger

    def initialize(path_to_csv:, logger: Rails.logger)
      @path_to_csv = path_to_csv
      @logger = logger
    end

    def add_cohort_to_lead_provider(row)
      start_year = row["cohort-start-year"].to_i
      lead_provider_name = row["lead-provider-name"]
      logger.info "AddCohortToLeadProvider: Adding Lead Provider: #{lead_provider_name} to cohort: #{start_year}"

      cohort = Cohort.find_by!(start_year:)
      lead_provider = LeadProvider.find_by!(name: lead_provider_name)

      lead_provider.cohorts << cohort

      logger.info "AddCohortToLeadProvider: Cohort #{start_year} added to Lead Provider: #{lead_provider_name} successfully"
    end

    def check_headers!
      unless %w[lead-provider-name cohort-start-year].all? { |header| rows.headers.include?(header) }
        raise NameError, "Invalid headers"
      end
    end

    def rows
      @rows ||= CSV.read(path_to_csv, headers: true)
    end
  end
end
