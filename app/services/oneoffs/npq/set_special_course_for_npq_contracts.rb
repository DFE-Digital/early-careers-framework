# frozen_string_literal: true

module Oneoffs::NPQ
  class SetSpecialCourseForNPQContracts
    def initialize(cohort_year:, payment_date_range:, course_identifier:)
      @cohort_year = cohort_year
      @payment_date_range = payment_date_range
      @course_identifier = course_identifier
    end

    def call
      ActiveRecord::Base.transaction do
        old_contracts = []

        statements.each do |statement|
          NPQContract.where(
            version: statement.contract_version,
            npq_lead_provider: statement.npq_lead_provider,
            cohort: statement.cohort,
          ).each do |contract|
            # Contract already set to true
            next if contract.special_course

            old_contracts << contract
          end
        end

        old_contracts.uniq!

        old_contracts.each do |old_contract|
          new_version = Finance::ECF::ContractVersion.new(old_contract.version).increment!

          new_contract = old_contract.dup
          new_contract.version = new_version
          new_contract.special_course = (old_contract.course_identifier == course_identifier)
          new_contract.save!

          statements.where(
            cpd_lead_provider: old_contract.npq_lead_provider.cpd_lead_provider,
            contract_version: old_contract.version,
          ).update!(contract_version: new_version)
        end
      end
    end

  private

    attr_reader :cohort_year, :payment_date_range, :course_identifier

    def cohort
      @cohort ||= Cohort.find_by!(start_year: cohort_year)
    end

    def statements
      @statements = Finance::Statement::NPQ.where(cohort:, payment_date: payment_date_range)
    end
  end
end
