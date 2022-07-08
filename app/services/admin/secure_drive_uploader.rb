# frozen_string_literal: true

require "google/apis/drive_v3"
require "googleauth"

module Admin
  class SecureDriveUploader
    attr_reader :file, :filename, :folder

    def initialize(file:, filename:, folder:)
      @file = file
      @filename = filename
      @folder = folder
    end

    def upload
      drive_service.create_file(
        file_metadata,
        upload_source: StringIO.new(file),
        supports_all_drives: true,
      )
    end

  private

    def drive_service
      @drive_service ||= Google::Apis::DriveV3::DriveService.new.tap do |service|
        service.authorization = authorization
      end
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

    def file_metadata
      {
        name: filename,
        parents: [
          folder,
        ],
      }
    end
  end
end
