# frozen_string_literal: true

require "csv"

module Oneoffs
  class UpdateMentorContracts
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
          create_mentor_call_off_contract(lead_provider:, cohort:, contract_data:)
        end

        raise ActiveRecord::Rollback if dry_run
      end

      recorded_info
    end

  private

    def latest_existing_mentor_contract(lead_provider:, cohort:)
      mentor_call_off_contracts = MentorCallOffContract.where(
        lead_provider:,
        cohort:,
      ).all
      mentor_call_off_contracts.max_by { |contract| Finance::ECF::ContractVersion.new(contract.version).numerical_value }
    end

    def statements(lead_provider:, cohort:)
      Finance::Statement::ECF.where(
        cohort:,
        cpd_lead_provider: lead_provider.cpd_lead_provider,
      )
    end

    def create_mentor_call_off_contract(lead_provider:, cohort:, contract_data:)
      existing_mentor_contract = latest_existing_mentor_contract(lead_provider:, cohort:)
      record_info "Found existing contract with version '#{existing_mentor_contract.version}'" if existing_mentor_contract

      if existing_contract_matches_contract_data?(existing_mentor_contract:, contract_data:)
        record_info "Existing contract matches contract data, no need to update"
        return
      end

      version = Finance::ECF::ContractVersion.new(existing_mentor_contract&.version || "0.0.0").increment!
      record_info "Creating new mentor contract with version '#{version}'"
      MentorCallOffContract.create!(
        lead_provider:,
        cohort:,
        version:,
        recruitment_target: contract_data[:recruitment_target],
        payment_per_participant: contract_data[:payment_per_participant],
      )

      record_info "Updating ECF statements with new version '#{version}'"
      statements(lead_provider:, cohort:).update!(mentor_contract_version: version)

      record_info "Done"
    end

    def check_headers!
      unless %w[lead-provider-name cohort-start-year recruitment-target payment-per-participant].all? { |header| rows.headers.include?(header) }
        raise NameError, "Invalid CSV headers"
      end
    end

    def existing_contract_matches_contract_data?(existing_mentor_contract:, contract_data:)
      return false unless existing_mentor_contract

      existing_mentor_contract.recruitment_target.to_s == contract_data[:recruitment_target].to_s &&
        existing_mentor_contract.payment_per_participant.to_s == contract_data[:payment_per_participant].to_f.to_s
    end

    def rows
      @rows ||= CSV.read(@path_to_csv, headers: true)
    end

    def build_contract_data(row)
      {
        recruitment_target: row["recruitment-target"],
        payment_per_participant: row["payment-per-participant"],
      }
    end
  end
end
