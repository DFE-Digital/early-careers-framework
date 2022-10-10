# frozen_string_literal: true

module Finance
  module NPQ
    class AssuranceReport
      class Presenter
        def initialize(statement_id, query: nil)
          self.statement_id = statement_id
          self.query        = query
        end

        def to_csv
          participant_declarations
        end

        def participant_declarations
          @participant_declarations ||= query.participant_declarations.map do |participant_declaration|
            AssuranceReport.new(**participant_declaration.serializable_hash)
          end
        end

        def filename
          "NPQ-Declarations-#{npq_lead_provider.name.gsub(/\W/, '')}-Cohort#{statement.cohort.start_year}-#{statement.name.gsub(/\W/, '')}.csv"
        end

        def csv_headers
          [
            "Participant ID",
            "Participant Name",
            "TRN",
            "Course Identifier",
            "Schedule",
            "Eligible For Funding",
            "Lead Provider Name",
            "School Urn",
            "School Name",
            "Training Status",
            "Training Status Reason",
            "Declaration ID",
            "Declaration Status",
            "Declaration Type",
            "Declaration Date",
            "Declaration Created At",
            "Statement Name",
            "Statement ID",
          ]
        end

      private

        attr_accessor :statement_id
        attr_writer :query

        def query
          @query ||= Query.new(statement)
        end

        def statement
          @statement ||= Finance::Statement::NPQ.find(statement_id)
        end

        def npq_lead_provider
          statement.npq_lead_provider
        end
      end
    end
  end
end
