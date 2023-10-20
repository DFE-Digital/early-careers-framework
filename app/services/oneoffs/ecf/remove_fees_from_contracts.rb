# frozen_string_literal: true

require "semantic"

module Oneoffs::ECF
  class RemoveFeesFromContracts
    attr_reader :cohort_year, :from_date

    def initialize(cohort_year:, from_date:)
      @cohort_year = cohort_year
      @from_date = from_date.to_date
    end

    def call
      statements.each do |statement|
        lead_provider = statement.lead_provider
        version = statement.contract_version

        old_contract = CallOffContract.where(
          version:,
          lead_provider:,
          cohort:,
        ).first!

        # Contract already set to zero
        next if old_contract.monthly_service_fee.to_s == "0.0"

        new_version = Semantic::Version.new(version).patch!.to_s

        new_contract = CallOffContract.find_or_initialize_by(
          version: new_version,
          lead_provider:,
          cohort:,
        )

        new_contract.uplift_target = old_contract.uplift_target
        new_contract.uplift_amount = old_contract.uplift_amount
        new_contract.recruitment_target = old_contract.recruitment_target
        new_contract.set_up_fee = old_contract.set_up_fee
        new_contract.revised_target = old_contract.revised_target
        new_contract.monthly_service_fee = 0.0
        new_contract.save!

        if new_contract.participant_bands.empty?
          old_contract.participant_bands.each do |old_band|
            new_band = old_band.dup
            new_band.call_off_contract = new_contract
            new_band.save!
          end
        end

        statement.update!(contract_version: new_version)
      end
    end

    def cohort
      @cohort ||= Cohort.find_by!(start_year: cohort_year)
    end

    def statements
      @statements ||= Finance::Statement::ECF.where(cohort:).where("payment_date >= ?", from_date)
    end
  end
end
