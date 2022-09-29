# frozen_string_literal: true

module Finance
  module NPQ
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
        @assurance_report_rows ||= AssuranceReport
                                     .where(
                                       npq_lead_provider_id: params[:lead_provider_id],
                                       statement_id: params[:statement_id],
                                     )
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

      def filename
        "NPQ-Declarations-#{npq_lead_provider.name.gsub(/\W/, '')}-Cohort#{statement.cohort.start_year}-#{statement.name.gsub(/\W/, '')}.csv"
      end

      def npq_lead_provider
        @npq_lead_provider ||= NPQLeadProvider.find(params[:lead_provider_id])
      end

      def statement
        @statement ||= Finance::Statement::NPQ.find(params[:statement_id])
      end
    end
  end
end
