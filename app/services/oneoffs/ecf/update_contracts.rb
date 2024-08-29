# frozen_string_literal: true

require "csv"

module Oneoffs::ECF
  class UpdateContracts
    include HasRecordableInformation

    def initialize(path_to_csv:)
      @path_to_csv = path_to_csv
    end

    def perform_change(dry_run: true)
      reset_recorded_info

      check_headers!

      record_info("~~~ DRY RUN ~~~") if dry_run

      ActiveRecord::Base.transaction do
        rows.each do |row|
          record_info("Looking at provider '#{row['lead-provider-name']}' for cohort '#{row['cohort-start-year']}'")

          cohort = Cohort.find_by!(start_year: row["cohort-start-year"].to_i)
          lead_provider = LeadProvider.joins(:cohorts).find_by!(name: row["lead-provider-name"], cohorts: { start_year: row["cohort-start-year"].to_i })

          contract_data = build_contract_data(row)
          update_or_create_contract(lead_provider:, cohort:, contract_data:)
        end

        raise ActiveRecord::Rollback if dry_run
      end

      recorded_info
    end

    def latest_existing_contract(lead_provider:, cohort:)
      call_off_contracts = CallOffContract.where(
        lead_provider:,
        cohort:,
      ).all
      call_off_contracts.max_by { |c| Finance::ECF::ContractVersion.new(c.version).numerical_value }
    end

    def statements(lead_provider:, cohort:)
      Finance::Statement::ECF.where(
        cohort:,
        cpd_lead_provider: lead_provider.cpd_lead_provider,
      )
    end

    def update_or_create_contract(lead_provider:, cohort:, contract_data:)
      existing_contract = latest_existing_contract(lead_provider:, cohort:)
      record_info "Found existing contract with version '#{existing_contract.version}'" if existing_contract

      if existing_contract_matches_contract_data?(existing_contract:, contract_data:)
        record_info "Existing contract matches contract data, no need to update"
        return
      end

      version = Finance::ECF::ContractVersion.new(existing_contract&.version || "0.0.0").increment!
      record_info "Creating new contract with version '#{version}'"
      call_off_contract = CallOffContract.create!(
        lead_provider:,
        cohort:,
        version:,
        uplift_target: contract_data[:uplift_target],
        uplift_amount: contract_data[:uplift_amount],
        recruitment_target: contract_data[:recruitment_target],
        revised_target: contract_data[:revised_target],
        set_up_fee: contract_data[:set_up_fee],
        monthly_service_fee: contract_data[:monthly_service_fee],
        raw: contract_data.to_json,
      )

      %i[band_a band_b band_c band_d].each do |band|
        record_info "Creating new band: #{band}"
        band_data = contract_data[band]
        create_participant_band!(call_off_contract:, band_data:, band_d: band == :band_d)
      end

      record_info "Updating ECF statements with new version '#{version}'"
      statements(lead_provider:, cohort:).update!(contract_version: version)

      record_info "Done"
    end

    def check_headers!
      expected_headers = %w[lead-provider-name cohort-start-year uplift-target uplift-amount recruitment-target revised-target set-up-fee monthly-service-fee band-a-min band-a-max band-a-per-participant band-b-min band-b-max band-b-per-participant band-c-min band-c-max band-c-per-participant band-d-min band-d-max band-d-per-participant]
      unless expected_headers.all? { |header| rows.headers.include?(header) }
        raise NameError, "Invalid CSV headers"
      end
    end

    def existing_contract_matches_contract_data?(existing_contract:, contract_data:)
      return false unless existing_contract

      existing_contract.uplift_target.to_s == contract_data[:uplift_target].to_f.to_s &&
        existing_contract.uplift_amount.to_s == contract_data[:uplift_amount].to_f.to_s &&
        existing_contract.recruitment_target == contract_data[:recruitment_target].to_i &&
        existing_contract.revised_target == contract_data[:revised_target].to_i &&
        existing_contract.set_up_fee.to_s == contract_data[:set_up_fee].to_f.to_s &&
        existing_contract.monthly_service_fee.to_s == contract_data[:monthly_service_fee].to_f.to_s &&

        existing_contract.bands[0]&.min.to_i == contract_data[:band_a][:min].to_i &&
        existing_contract.bands[0]&.max.to_i == contract_data[:band_a][:max].to_i &&
        existing_contract.bands[0]&.per_participant.to_f.to_s == contract_data[:band_a][:per_participant].to_f.to_s &&

        existing_contract.bands[1]&.min.to_i == contract_data[:band_b][:min].to_i &&
        existing_contract.bands[1]&.max.to_i == contract_data[:band_b][:max].to_i &&
        existing_contract.bands[1]&.per_participant.to_f.to_s == contract_data[:band_b][:per_participant].to_f.to_s &&

        existing_contract.bands[2]&.min.to_i == contract_data[:band_c][:min].to_i &&
        existing_contract.bands[2]&.max.to_i == contract_data[:band_c][:max].to_i &&
        existing_contract.bands[2]&.per_participant.to_f.to_s == contract_data[:band_c][:per_participant].to_f.to_s &&

        existing_contract.bands[3]&.min.to_i == contract_data[:band_d][:min].to_i &&
        existing_contract.bands[3]&.max.to_i == contract_data[:band_d][:max].to_i &&
        existing_contract.bands[3]&.per_participant.to_f.to_s == contract_data[:band_d][:per_participant].to_f.to_s
    end

    def rows
      @rows ||= CSV.read(@path_to_csv, headers: true)
    end

    def create_participant_band!(call_off_contract:, band_data:, band_d: false)
      return if band_data.values.all?(&:blank?)

      attributes = {
        call_off_contract:,
        min: band_data[:min],
        max: band_data[:max],
        per_participant: band_data[:per_participant],
      }

      attributes.merge!(output_payment_percentage: 100, service_fee_percentage: 0) if band_d
      ParticipantBand.create!(**attributes)
    end

    def build_contract_data(row)
      {
        uplift_target: row["uplift-target"],
        uplift_amount: row["uplift-amount"],
        recruitment_target: row["recruitment-target"],
        revised_target: row["revised-target"],
        set_up_fee: row["set-up-fee"],
        monthly_service_fee: row["monthly-service-fee"],
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
