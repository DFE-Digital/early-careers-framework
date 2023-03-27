# frozen_string_literal: true

require "csv"

module Importers
  # Given a CSV with correct data
  # Find or create NPQContract
  class NPQContracts
    attr_reader :path_to_csv

    def initialize(path_to_csv:)
      @path_to_csv = path_to_csv
    end

    def call
      check_headers

      rows.each do |row|
        cohort = Cohort.find_by!(start_year: row["cohort_year"])
        cpd_lead_provider = CpdLeadProvider.find_by!(name: row["provider_name"])
        npq_lead_provider = cpd_lead_provider.npq_lead_provider
        course = NPQCourse.find_by!(identifier: row["course_identifier"])

        # We only create/update version 0.0.1 for initial values
        # Manually create new version of contract if there are changes
        contract = NPQContract.find_or_initialize_by(
          cohort:,
          version: "0.0.1",
          npq_lead_provider:,
          course_identifier: course.identifier,
        )

        contract.update!(
          recruitment_target: row["recruitment_target"].to_i,
          per_participant: row["per_participant"],
          service_fee_installments: row["service_fee_installments"].to_i,
          number_of_payment_periods: number_of_payment_periods_for(course:),
          service_fee_percentage: service_fee_percentage_for(course:),
          output_payment_percentage: output_payment_percentage_for(course:),
        )
      end
    end

  private

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

    def check_headers
      unless rows.headers == %w[provider_name cohort_year course_identifier recruitment_target per_participant service_fee_installments]
        raise NameError, "Invalid headers"
      end
    end

    def rows
      @rows ||= CSV.read(path_to_csv, headers: true, skip_blanks: true)
    end
  end
end
