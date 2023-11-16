# frozen_string_literal: true

module Oneoffs::ECF
  class AddBandC
    def initialize(cohort_year:, cpd_lead_provider:, payment_date_range:, band_c_params:)
      @cohort_year = cohort_year
      @cpd_lead_provider = cpd_lead_provider
      @payment_date_range = payment_date_range
      @band_c_params = band_c_params
    end

    def call
      ActiveRecord::Base.transaction do
        old_contracts = []

        statements.each do |statement|
          CallOffContract.where(
            version: statement.contract_version,
            lead_provider: statement.cpd_lead_provider.lead_provider,
            cohort: statement.cohort,
          ).each do |contract|
            # Contract already has Band C
            next if contract.bands.count > 2

            old_contracts << contract
          end
        end

        old_contracts.uniq!

        old_contracts.each do |old_contract|
          new_version = Finance::ECF::ContractVersion.new(old_contract.version).increment!

          new_contract = old_contract.dup
          new_contract.version = new_version
          new_contract.recruitment_target = band_c_params[:max]
          new_contract.revised_target = band_c_params[:max]
          new_contract.save!

          old_contract.participant_bands.each do |old_band|
            new_band = old_band.dup
            new_band.call_off_contract = new_contract
            new_band.save!
          end

          old_band = new_contract.bands[1]
          old_band.update!(max: band_c_params[:min] - 1)

          new_contract.participant_bands.create!(band_c_params)

          statements.where(
            contract_version: old_contract.version,
          ).update!(contract_version: new_version)
        end
      end
    end

  private

    attr_reader :cohort_year, :payment_date_range, :cpd_lead_provider, :band_c_params

    delegate :lead_provider, to: :cpd_lead_provider

    def cohort
      @cohort ||= Cohort.find_by!(start_year: cohort_year)
    end

    def statements
      @statements = Finance::Statement::ECF.where(cohort:, payment_date: payment_date_range, cpd_lead_provider:)
    end
  end
end
