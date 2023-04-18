# frozen_string_literal: true

require "csv"

module Importers
  class CreateCallOffContract
    def call
      logger.info "CreateCallOffContract: Started!"

      if path_to_csv.present?
        create_call_off_contracts_from_csv
      else
        create_default_call_off_contracts
      end

      logger.info "CreateCallOffContract: Finished!"
    end

  private

    attr_reader :path_to_csv, :logger

    def initialize(path_to_csv: nil, logger: Rails.logger)
      @path_to_csv = path_to_csv
      @logger = logger
    end

    def create_default_call_off_contracts
      raise "Do not seed default Call off Contracts in Production!" if Rails.env.production?

      LeadProvider.all.each do |lead_provider|
        [cohort_current, cohort_previous, cohort_next].each do |cohort|
          create_call_off_contract_and_bands(lead_provider:, cohort:, contract_data: example_contract_data)
        end
      end
    end

    def create_call_off_contracts_from_csv
      check_headers!

      ActiveRecord::Base.transaction do
        rows.each do |row|
          cohort = Cohort.find_by!(start_year: row["cohort-start-year"].to_i)
          lead_provider = LeadProvider.joins(:cohorts).find_by!(name: row["lead-provider-name"], cohorts: { start_year: row["cohort-start-year"].to_i })

          call_off_contract = CallOffContract.find_by(
            lead_provider:,
            cohort:,
          )

          next if call_off_contract

          contract_data = build_contract_data(row)
          create_call_off_contract_and_bands(lead_provider:, cohort:, contract_data:)
        end
      end
    end

    def create_call_off_contract_and_bands(lead_provider:, cohort:, contract_data:)
      logger.info "CreateCallOffContract: Adding Call off Contract for Lead Provider: #{lead_provider.name} in cohort: #{cohort.start_year}"
      call_off_contract = create_call_off_contract!(lead_provider:, contract_data:, cohort:)

      logger.info "CreateCallOffContract: Adding bands to Call off Contract for Lead Provider: #{lead_provider.name} in cohort: #{cohort.start_year}"
      %i[band_a band_b band_c band_d].each do |band|
        band_data = contract_data[band]
        create_participant_band!(call_off_contract:, band_data:, band_d: band == :band_d)
      end
      logger.info "CreateCallOffContract: Added Call off Contract and bands for Lead Provider: #{lead_provider.name} in cohort: #{cohort.start_year} successfully!"
    end

    def check_headers!
      unless %w[lead-provider-name cohort-start-year uplift-target uplift-amount recruitment-target revised-target set-up-fee band-a-min band-a-max band-a-per-participant band-b-min band-b-max band-b-per-participant band-c-min band-c-max band-c-per-participant band-d-min band-d-max band-d-per-participant].all? { |header| rows.headers.include?(header) }
        raise NameError, "Invalid headers"
      end
    end

    def rows
      @rows ||= CSV.read(path_to_csv, headers: true)
    end

    def create_call_off_contract!(lead_provider:, contract_data:, cohort:)
      CallOffContract.create!(
        lead_provider:,
        cohort:,
        uplift_target: contract_data[:uplift_target],
        uplift_amount: contract_data[:uplift_amount],
        recruitment_target: contract_data[:recruitment_target],
        revised_target: contract_data[:revised_target],
        set_up_fee: contract_data[:set_up_fee],
        raw: contract_data.to_json,
      )
    end

    def create_participant_band!(call_off_contract:, band_data:, band_d: false)
      attributes = {
        call_off_contract:,
        min: band_data[:min],
        max: band_data[:max],
        per_participant: band_data[:per_participant],
      }

      attributes.merge!(output_payment_percantage: 100, service_fee_percentage: 0) if band_d
      ParticipantBand.create!(**attributes)
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
        uplift_target: 0.33,
        uplift_amount: 100,
        recruitment_target: 4500,
        revised_target: (4500 * 1.02).to_i,
        set_up_fee: 0,
        band_a: {
          min: 0,
          max: 10,
          per_participant: 995,
        },
        band_b: {
          min: 11,
          max: 20,
          per_participant: 979,
        },
        band_c: {
          min: 21,
          max: 30,
          per_participant: 966,
        },
        band_d: {
          min: 31,
          max: 40,
          per_participant: 966,
        },
      }
    end

    def build_contract_data(row)
      {
        uplift_target: row["uplift-target"],
        uplift_amount: row["uplift-amount"],
        recruitment_target: row["recruitment-target"],
        revised_target: row["revised-target"],
        set_up_fee: row["set-up-fee"],
        band_a: {
          min: row["band-a-min"],
          max: row["band-a-max"],
          per_participant: row["band-a-per-participant"],
        },
        band_b: {
          min: row["band-b-min"],
          max: row["band-b-max"],
          per_participant: row["band-b-per-participant"],
        },
        band_c: {
          min: row["band-c-min"],
          max: row["band-c-max"],
          per_participant: row["band-c-per-participant"],
        },
        band_d: {
          min: row["band-d-min"],
          max: row["band-d-max"],
          per_participant: row["band-d-per-participant"],
        },
      }
    end
  end
end
