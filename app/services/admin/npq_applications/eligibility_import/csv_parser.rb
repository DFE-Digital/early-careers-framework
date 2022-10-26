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
          @data ||= valid? ? parsed_csv_rows : []
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
          if csv_file.headers != REQUIRED_CSV_HEADERS
            errors.append(INVALID_HEADERS_ERROR).uniq!
            return
          end

          parsed_csv_rows.each(&method(:validate_row))
        end

        def parsed_csv_rows
          csv_file.each_with_index.map do |row, index|
            csv_row = index + 2

            # We don't want to coerce unclear values into false
            # We need an *explicit* value that is either TRUE or FALSE (case insensitively)
            cleaned_eligible_for_funding = row["eligible_for_funding"]&.strip&.upcase
            eligible_for_funding_value = if %w[TRUE FALSE].include?(cleaned_eligible_for_funding)
                                           cleaned_eligible_for_funding == "TRUE"
                                         end

            OpenStruct.new(
              csv_row:,
              ecf_id: row["ecf_id"]&.strip,
              eligible_for_funding: eligible_for_funding_value,
              funding_eligiblity_status_code: row["funding_eligiblity_status_code"]&.strip,
            )
          end
        end

        def validate_row(csv_row)
          errors.append("Row #{csv_row.csv_row}: ecf_id is blank") if csv_row.ecf_id.blank?
          errors.append("Row #{csv_row.csv_row}: funding_eligiblity_status_code is blank") if csv_row.funding_eligiblity_status_code.blank?
          errors.append("Row #{csv_row.csv_row}: eligible_for_funding must be either TRUE or FALSE") if csv_row.eligible_for_funding.nil?
        end
      end
    end
  end
end
