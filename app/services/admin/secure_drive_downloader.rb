# frozen_string_literal: true

require "google/apis/drive_v3"
require "googleauth"

module Admin
  class SecureDriveDownloader
    attr_reader :filename, :folder

    def initialize(filename:, folder:)
      @filename = filename
      @folder = folder
    end

    def file
      return false if matching_file.blank?

      stringio = StringIO.new

      drive_service.get_file(
        matching_file.id,
        download_dest: stringio,
        supports_all_drives: true,
      )

      stringio.tap(&:rewind).read
    rescue StandardError => e
      Sentry.capture_exception(
        e,
        hint: {
          filename:,
          folder:,
        },
      )

      errors.append("Error downloading file, contact an administrator for details")
      false
    end

    def list_files
      drive_service.list_files(
        q: search_query,
        supports_all_drives: true,
        include_items_from_all_drives: true,
        corpora: "allDrives",
      )
    end

    def errors
      @errors ||= []
    end

  private

    def drive_service
      @drive_service ||= Google::Apis::DriveV3::DriveService.new.tap do |service|
        service.authorization = authorization
      end
    end

    def search_query
      %W[name = '#{filename}' and '#{folder}' in parents].join(" ")
    end

    def matching_file
      if matching_files.many?
        errors.append("More than one file was found with name #{filename}. To avoid ambiguity the import was cancelled.")
        return
      end

      if matching_files.none?
        errors.append("File not found")
        return
      end

      matching_files.first
    end

    def matching_files
      @matching_files ||= list_files.files
    end

    def authorization
      @authorization ||= ::Google::Auth::ServiceAccountCredentials.make_creds(
        scope: [
          "https://www.googleapis.com/auth/drive.file",
          "https://www.googleapis.com/auth/drive",
          "https://www.googleapis.com/auth/drive.file",
          "https://www.googleapis.com/auth/drive.metadata",
        ],
      )
    end
  end
end
