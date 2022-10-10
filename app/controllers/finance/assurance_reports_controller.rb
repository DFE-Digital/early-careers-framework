# frozen_string_literal: true

module Finance
  class AssuranceReportsController < BaseController
    def show
      respond_to do |format|
        format.csv { send_data(generate_csv, filename: assurance_report_presenter.filename) }
      end
    end

  private

    def filename
      assurance_report_presenter.filename
    end

    def generate_csv
      CSVSerialiser.serialise(assurance_report_presenter)
    end
  end
end
