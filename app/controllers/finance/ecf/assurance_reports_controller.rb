# frozen_string_literal: true

require "csv_serialiser"

module Finance
  module ECF
    class AssuranceReportsController < Finance::AssuranceReportsController
    private

      def assurance_report_presenter
        @assurance_report_presenter ||= AssuranceReport::Presenter.new(params[:statement_id])
      end
    end
  end
end
