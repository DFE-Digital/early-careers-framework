# frozen_string_literal: true

module Finance
  module ECF
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
          "ECF-Declarations-#{lead_provider.name.gsub(/\W/, '')}-Cohort#{statement.cohort.start_year}-#{statement.name.gsub(/\W/, '')}.csv"
        end

        def csv_headers
          [
            "Participant ID",
            "Participant Name",
            "TRN",
            "Type",
            "Mentor Profile ID",
            "Schedule",
            "Eligible For Funding",
            "Eligible For Funding Reason",
            "Sparsity Uplift",
            "Pupil Premium Uplift",
            "Sparsity And Pp",
            "Lead Provider Name",
            "Delivery Partner Name",
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
          @statement ||= Finance::Statement::ECF.find(statement_id)
        end

        def lead_provider
          @statement.lead_provider
        end
      end
    end
  end
end
