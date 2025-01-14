# frozen_string_literal: true

require "csv"

module Importers
  class CreateMentorCallOffContract
    def call
      logger.info "CreateMentorCallOffContract: Started!"

      if path_to_csv.present?
        create_mentor_call_off_contract_from_csv
      else
        create_default_mentor_call_off_contracts
      end

      logger.info "CreateMentorCallOffContract: Finished!"
    end

  private

    attr_reader :path_to_csv, :logger

    def initialize(path_to_csv: nil, logger: Rails.logger)
      @path_to_csv = path_to_csv
      @logger = logger
    end

    def create_default_mentor_call_off_contracts
      raise "Do not seed default Mentor Call Off Contracts in Production!" if Rails.env.production?

      LeadProvider.find_each do |lead_provider|
        [cohort_current, cohort_previous, cohort_next].each do |cohort|
          create_mentor_call_off_contract(lead_provider:, cohort:, contract_data: example_contract_data)
        end
      end
    end

    def create_mentor_call_off_contract_from_csv
      check_headers!

      ActiveRecord::Base.transaction do
        rows.each do |row|
          cohort = Cohort.find_by!(start_year: row["cohort-start-year"].to_i)
          lead_provider = LeadProvider.joins(:cohorts).find_by!(name: row["lead-provider-name"], cohorts: { start_year: row["cohort-start-year"].to_i })

          mentor_call_off_contract = MentorCallOffContract.find_by(
            lead_provider:,
            cohort:,
          )

          next if mentor_call_off_contract

          contract_data = build_contract_data(row)
          create_mentor_call_off_contract(lead_provider:, cohort:, contract_data:)
        end
      end
    end

    def create_mentor_call_off_contract(lead_provider:, cohort:, contract_data:)
      logger.info "CreateMentorCallOffContract: Adding Mentor Call Off Contract for Lead Provider: #{lead_provider.name} in cohort: #{cohort.start_year}"

      MentorCallOffContract.create!(
        lead_provider:,
        cohort:,
        recruitment_target: contract_data[:recruitment_target],
        payment_per_participant: contract_data[:payment_per_participant],
      )

      logger.info "CreateMentorCallOffContract: Added Mentor Call Off Contract for Lead Provider: #{lead_provider.name} in cohort: #{cohort.start_year} successfully!"
    end

    def check_headers!
      unless %w[lead-provider-name cohort-start-year recruitment-target payment-per-participant].all? { |header| rows.headers.include?(header) }
        raise NameError, "Invalid headers"
      end
    end

    def rows
      @rows ||= CSV.read(path_to_csv, headers: true)
    end

    def cohort_current
      @cohort_current ||= Cohort.current || FactoryBot.create(:cohort, :current)
    end

    def cohort_previous
      @cohort_previous ||= Cohort.previous || FactoryBot.create(:cohort, :previous)
    end

    def cohort_next
      @cohort_next ||= Cohort.next || FactoryBot.create(:cohort, :next)
    end

    def example_contract_data
      @example_contract_data ||= {
        recruitment_target: 4500,
        payment_per_participant: 1000.0,
      }
    end

    def build_contract_data(row)
      {
        recruitment_target: row["recruitment-target"],
        payment_per_participant: row["payment-per-participant"],
      }
    end
  end
end
