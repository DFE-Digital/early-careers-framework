# frozen_string_literal: true

module Oneoffs::NPQ
  class CreateNewContractAndUpdateExistingStatements
    def initialize(path_to_csv:, cohort_year:, payment_date_range:)
      @path_to_csv = path_to_csv
      @cohort_year = cohort_year
      @payment_date_range = payment_date_range
    end

    def call
      ActiveRecord::Base.transaction do
        rows_by_provider.each do |provider_name, rows|
          cpd_lead_provider = CpdLeadProvider.find_by!(name: provider_name)
          npq_lead_provider = cpd_lead_provider.npq_lead_provider
          new_contracts = []

          rows.each.with_index(1) do |row, index|
            cohort = Cohort.find_by!(start_year: row["cohort_year"])
            course = NPQCourse.find_by!(identifier: row["course_identifier"])

            current_version = Finance::Statement::NPQ.where(cohort:, cpd_lead_provider:).pluck(:contract_version).max
            new_version = Finance::ECF::ContractVersion.new(current_version).increment!

            new_contract = NPQContract.find_or_initialize_by(
              cohort:,
              version: new_version,
              npq_lead_provider:,
              course_identifier: course.identifier,
            )

            new_contract.update!(
              monthly_service_fee: row["monthly_service_fee"] || 0.0,
              recruitment_target: row["recruitment_target"].to_i,
              per_participant: row["per_participant"],
              service_fee_installments: row["service_fee_installments"].to_i,
              number_of_payment_periods: number_of_payment_periods_for(course:),
              service_fee_percentage: service_fee_percentage_for(course:),
              output_payment_percentage: output_payment_percentage_for(course:),
              special_course: (row["special_course"].to_s.upcase == "TRUE"),
              funding_cap: row["funding_cap"],
            )

            new_contracts << new_contract

            next unless index == rows.size

            other_lp_contracts = NPQContract.where(cohort:, version: current_version, npq_lead_provider:)
                                            .where.not(course_identifier: new_contracts.map(&:course_identifier))

            other_lp_contracts.each do |contract|
              new_contract = contract.dup
              new_contract.update!(version: new_version)
            end

            statements = Finance::Statement::NPQ.where(cohort:, payment_date: payment_date_range, cpd_lead_provider:)
            statements.find_each do |statement|
              statement.update!(contract_version: new_version)
            end
          end
        end
      end
    end

  private

    attr_reader :path_to_csv, :cohort_year, :payment_date_range

    def number_of_payment_periods_for(course:)
      case course.identifier
      when *Finance::Schedule::NPQLeadership::IDENTIFIERS
        4
      when *Finance::Schedule::NPQSpecialist::IDENTIFIERS
        3
      when *Finance::Schedule::NPQSupport::IDENTIFIERS
        4
      when *Finance::Schedule::NPQEhco::IDENTIFIERS
        4
      else
        raise ArgumentError, "Invalid course identifier"
      end
    end

    def service_fee_percentage_for(course:)
      case course.identifier
      when *Finance::Schedule::NPQSupport::IDENTIFIERS
        0
      when *Finance::Schedule::NPQEhco::IDENTIFIERS
        0
      else
        40
      end
    end

    def output_payment_percentage_for(course:)
      case course.identifier
      when *Finance::Schedule::NPQSupport::IDENTIFIERS
        100
      when *Finance::Schedule::NPQEhco::IDENTIFIERS
        100
      else
        60
      end
    end

    def rows_by_provider
      rows.group_by { |row| row["provider_name"] }
    end

    def rows
      @rows ||= CSV.read(path_to_csv, headers: true, skip_blanks: true)
    end
  end
end
