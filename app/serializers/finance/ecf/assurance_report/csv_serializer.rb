# frozen_string_literal: true

module Finance
  module ECF
    module AssuranceReport
      class CsvSerializer
        CSV_HEADERS = [
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
        ].freeze

        def initialize(scope, statement)
          self.scope     = scope
          self.statement = statement
        end

        def filename
          "ECF-Declarations-#{lead_provider.name.gsub(/\W/, '')}-Cohort#{statement.cohort.start_year}-#{statement.name.gsub(/\W/, '')}.csv"
        end

        def call
          CSV.generate do |csv|
            csv << CSV_HEADERS

            scope.each do |record|
              csv << to_row(record)
            end
          end
        end

      private

        attr_accessor :scope, :statement

        def to_row(record)
          [
            record.participant_id,
            record.participant_name,
            record.trn,
            record.participant_type,
            record.mentor_profile_id,
            record.schedule,
            record.eligible_for_funding,
            record.eligible_for_funding_reason,
            record.sparsity_uplift,
            record.pupil_premium_uplift,
            record.sparsity_and_pp,
            record.lead_provider_name,
            record.delivery_partner_name,
            record.school_urn,
            record.school_name,
            record.training_status,
            record.training_status_reason,
            record.declaration_id,
            record.declaration_status,
            record.declaration_type,
            record.declaration_date.iso8601,
            record.declaration_created_at.iso8601,
            record.statement_name,
            record.statement_id,
          ]
        end

        def lead_provider
          statement.lead_provider
        end
      end
    end
  end
end
