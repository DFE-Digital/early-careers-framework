# frozen_string_literal: true

module Finance
  class AssuranceReportsController < BaseController
    def show
      respond_to do |format|
        format.csv { send_data(csv_serializer.call, filename:) }
      end
    end

  private

    def filename
      csv_serializer.filename
    end
  end
end
