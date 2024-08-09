# frozen_string_literal: true

require "has_recordable_information"

module Oneoffs::ECF
  class ChangeServiceFees
    class CallOffContractNotFoundError < StandardError; end

    include HasRecordableInformation

    delegate :lead_provider, to: :cpd_lead_provider, private: true

    def initialize(cpd_lead_provider:, cohort:)
      @cpd_lead_provider = cpd_lead_provider
      @cohort = cohort
    end

    def perform_change(payment_date_range:, monthly_service_fee:, dry_run: true)
      reset_recorded_info

      record_info("~~~ DRY RUN ~~~") if dry_run

      ActiveRecord::Base.transaction do
        contract = create_contract(monthly_service_fee)

        record_info("Latest contract version: #{latest_call_off_contract.version}, fee: #{format_fee(latest_call_off_contract)}")
        record_info("New contract version: #{contract.version}, fee: #{format_fee(contract)}")

        create_participant_bands(contract)
        update_statement_contract_versions(payment_date_range, contract.version)

        raise ActiveRecord::Rollback if dry_run
      end

      recorded_info
    end

  private

    attr_reader :cpd_lead_provider, :cohort

    def latest_call_off_contract
      @latest_call_off_contract ||= CallOffContract
        .where(lead_provider:, cohort:)
        .max_by { |c| Finance::ECF::ContractVersion.new(c.version).numerical_value }
    end

    def create_contract(monthly_service_fee)
      raise CallOffContractNotFoundError unless latest_call_off_contract

      latest_call_off_contract.dup.tap do |c|
        c.version = Finance::ECF::ContractVersion.new(c.version).increment!
        c.monthly_service_fee = monthly_service_fee
        c.save!
      end
    end

    def create_participant_bands(contract)
      latest_call_off_contract.participant_bands.each do |band|
        band.dup.tap { |b| b.call_off_contract = contract }.save!
      end
    end

    def update_statement_contract_versions(payment_date_range, contract_version)
      statements(payment_date_range).each do |s|
        record_info("Updating statement (#{s.id}) dated: #{s.payment_date} (version: #{s.contract.version}, fee: #{format_fee(s.contract)})")
        s.update!(contract_version:)
      end
    end

    def statements(payment_date_range)
      @statements ||= Finance::Statement::ECF
        .where(cohort:, cpd_lead_provider:, payment_date: payment_date_range)
        .order(:payment_date)
    end

    def format_fee(contract)
      contract.monthly_service_fee.nil? ? "nil" : contract.monthly_service_fee
    end
  end
end
