# frozen_string_literal: true

# NOTE: This job is intended to be used temporarily while we migrate
# PartnershipCsvUpload away from active storage to using an PostgreSQL array.
class SyncPartnershipCsvUploadJob < ApplicationJob
  def perform(partnership_csv_upload_id:)
    PartnershipCsvUpload.find(partnership_csv_upload_id).sync_uploaded_urns
  end
end
