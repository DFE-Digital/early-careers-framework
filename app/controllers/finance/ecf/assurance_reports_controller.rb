# frozen_string_literal: true

module Finance
  module ECF
    class AssuranceReportsController < BaseController
      def show
        send_data(generate_csv, filename:)
      end

    private

      def generate_csv
        CSV.generate do |csv|
          csv << csv_headers
          assurance_report_rows.each do |assurance_report_row|
            csv << assurance_report_row.to_csv
          end
        end
      end

      def assurance_report_rows
        @assurance_report_rows ||= AssuranceReport.new(params[:lead_provider_id], params[:statement_id].rows)
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

      def filename
        "ECF-Declarations-#{lead_provider.name.gsub(/\W/, '')}-Cohort#{statement.cohort.start_year}-#{statement.name.gsub(/\W/, '')}.csv"
      end

      def lead_provider
        @lead_provider ||= LeadProvider.find(params[:lead_provider_id])
      end

      def statement
        @statement ||= Finance::Statement::ECF.find(params[:statement_id])
      end
    end
  end
end
