# frozen_string_literal: true

module Finance
  module NPQ
    class AssuranceReportsController < Finance::AssuranceReportsController
    private

      def csv_serializer
        @csv_serializer ||= AssuranceReport::CSVSerializer.new(query.participant_declarations, statement)
      end

      def query
        @query ||= AssuranceReport::Query.new(statement)
      end

      def statement
        @statement ||= Finance::Statement::NPQ.find(params[:statement_id])
      end
    end
  end
end
