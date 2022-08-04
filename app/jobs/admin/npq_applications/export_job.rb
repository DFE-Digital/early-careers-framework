# frozen_string_literal: true

module Admin
  module NPQApplications
    class ExportJob < ApplicationJob
      queue_as :default

      def perform(npq_application_export)
        start_date = npq_application_export.start_date
        end_date = npq_application_export.end_date

        csv_generator = Admin::NPQApplications::CsvGenerator.new(start_date:, end_date:)

        uploader = Admin::SecureDriveUploader.new(
          file: csv_generator.csv,
          filename: filename(start_date, end_date),
          folder: ENV["GOOGLE_DRIVE_NPQ_UPLOAD_FOLDER_ID"],
        )

        uploader.upload
      end

    private

      def current_time
        Time.zone.now.to_i
      end

      def date_to_string(date)
        date.to_date.to_s
      end

      def filename(start_date, end_date)
        "npq-applications-#{date_to_string(start_date)}-till-#{date_to_string(end_date)}-#{current_time}.csv"
      end
    end
  end
end
