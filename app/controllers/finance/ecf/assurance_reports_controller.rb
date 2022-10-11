# frozen_string_literal: true

module Finance
  module ECF
    class AssuranceReportsController < Finance::AssuranceReportsController
    private

      def csv_serializer
        @csv_serializer ||= AssuranceReportSerializer.new(query.participant_declarations, statement)
      end

      def query
        @query ||= AssuranceReport::Query.new(statement)
      end

      def statement
        @statement ||= Finance::Statement::ECF.find(params[:statement_id])
      end
    end
  end
end
