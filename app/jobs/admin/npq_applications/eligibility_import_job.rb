# frozen_string_literal: true

module Admin
  module NPQApplications
    class EligibilityImportJob < ApplicationJob
      queue_as :default

      def perform(eligibility_import)
        ActiveRecord::Base.transaction do
          eligibility_import.begin_processing!

          downloader = Admin::SecureDriveDownloader.new(
            filename: eligibility_import.filename.strip,
            folder: ENV["GOOGLE_DRIVE_NPQ_DOWNLOAD_FOLDER_ID"],
          )

          file = downloader.file

          if file.present?
            csv_parser = Admin::NPQApplications::EligibilityImport::CsvParser.new(file:)

            if csv_parser.valid?
              eligibility_updater = Admin::NPQApplications::EligibilityImport::ApplicationUpdater.new(
                eligibility_import:,
                application_updates: csv_parser.data,
                user: eligibility_import.user,
              )

              eligibility_updater.update_applications

              eligibility_import.import_errors.concat(eligibility_updater.update_errors)
              eligibility_import.updated_records = eligibility_updater.updated_records

              eligibility_import.complete!
            else
              eligibility_import.import_errors.concat(csv_parser.errors)
              eligibility_import.fail!
            end
          else
            eligibility_import.import_errors.concat(downloader.errors)
            eligibility_import.fail!
          end
        end
      rescue StandardError => e
        Sentry.with_scope do |scope|
          scope.set_context("NPQ Eligibility Import Record", id: eligibility_import.id)
          Sentry.capture_exception(e)
        end

        eligibility_import.import_errors.append("Processing Failed, contact an administrator for details")
        eligibility_import.fail!
      end
    end
  end
end
