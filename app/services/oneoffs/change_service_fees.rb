# frozen_string_literal: true

module Oneoffs
  class ChangeServiceFees
    class CallOffContractNotFoundError < StandardError; end

    attr_reader :changes
    delegate :lead_provider, to: :cpd_lead_provider, private: true

    def initialize(cpd_lead_provider:, cohort:)
      @cpd_lead_provider = cpd_lead_provider
      @cohort = cohort
    end

    def perform_change(date_range:, monthly_service_fee:, dry_run: true)
      @changes = []

      log_info("~~~ DRY RUN ~~~") if dry_run

      ActiveRecord::Base.transaction do
        contract = create_contract(monthly_service_fee)

        log_info("Current contract version: #{call_off_contract.version}, fee: #{call_off_contract.monthly_service_fee}")
        log_info("New contract version: #{contract.version}, fee: #{contract.monthly_service_fee}")

        create_participant_bands(contract)
        update_statement_contract_versions(date_range, contract.version)

        raise ActiveRecord::Rollback if dry_run
      end
    end

  private

    attr_reader :cpd_lead_provider, :cohort

    def call_off_contract
      @call_off_contract ||= CallOffContract
        .where(lead_provider:, cohort:)
        .order(version: :desc)
        .first
    end

    def create_contract(monthly_service_fee)
      raise CallOffContractNotFoundError unless call_off_contract

      call_off_contract.dup.tap do |c|
        c.version = increment_version(c.version)
        c.monthly_service_fee = monthly_service_fee
        c.save!
      end
    end

    def create_participant_bands(contract)
      call_off_contract.participant_bands.each do |band|
        band.dup.tap { |b| b.call_off_contract = contract }.save!
      end
    end

    def update_statement_contract_versions(date_range, contract_version)
      statements(date_range).each do |s|
        log_info("Updating statement dated: #{s.payment_date}")
        s.update!(contract_version:)
      end
    end

    def statements(date_range)
      @statements ||= Finance::Statement::ECF
        .where(cohort:, cpd_lead_provider:, payment_date: date_range)
    end

    def increment_version(version)
      major, minor, patch = version.split(".")
      "#{major}.#{minor}.#{patch.to_i + 1}"
    end

    def log_info(info)
      changes << info
      Rails.logger.info(info)
    end
  end
end
