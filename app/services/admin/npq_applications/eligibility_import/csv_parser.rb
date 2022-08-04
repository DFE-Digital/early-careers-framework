# frozen_string_literal: true

module Admin
  module NPQApplications
    module EligibilityImport
      class CsvParser
        REQUIRED_CSV_HEADERS = %w[ecf_id eligible_for_funding funding_eligiblity_status_code].freeze
        INVALID_HEADERS_ERROR = "Invalid CSV headers, required headers are: #{REQUIRED_CSV_HEADERS.join(', ')}".freeze

        attr_reader :errors

        def initialize(file:)
          @file = file
          @errors = []
        end

        def data
          @data ||= valid? ? extract_data : []
        end

        def valid?
          validate_file
          errors.empty?
        end

      private

        def csv_file
          @csv_file ||= CSV.parse(@file, headers: true)
        end

        def validate_file
          return if csv_file.headers == REQUIRED_CSV_HEADERS

          errors.append(INVALID_HEADERS_ERROR).uniq!
        end

        def extract_data
          csv_file.each_with_index.map do |row, index|
            csv_row = index + 2

            OpenStruct.new(
              csv_row:,
              ecf_id: row["ecf_id"],
              eligible_for_funding: row["eligible_for_funding"] == "TRUE",
              funding_eligiblity_status_code: row["funding_eligiblity_status_code"],
            )
          end
        end
      end
    end
  end
end
