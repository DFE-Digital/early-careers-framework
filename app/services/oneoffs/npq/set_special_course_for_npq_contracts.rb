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
        statements.each do |statement|
          npq_lead_provider = statement.npq_lead_provider
          version = statement.contract_version

          old_contract = NPQContract.where(
            version:,
            npq_lead_provider:,
            cohort:,
            course_identifier:,
          ).first!

          # Contract already set to true
          next if old_contract.special_course

          new_version = Finance::ECF::ContractVersion.new(version).increment!

          new_contract = old_contract.dup
          new_contract.version = new_version
          new_contract.special_course = true
          new_contract.save!

          statement.update!(contract_version: new_version)
        end
      end
    end

  private

    attr_reader :cohort_year, :payment_date_range, :course_identifier

    def cohort
      @cohort ||= Cohort.find_by!(start_year: cohort_year)
    end

    def statements
      @statements ||= Finance::Statement::NPQ.where(cohort:, payment_date: payment_date_range)
    end
  end
end
