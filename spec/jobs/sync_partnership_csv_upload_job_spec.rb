# frozen_string_literal: true

require "rails_helper"

RSpec.describe "SyncPartnershipCsvUploadJob" do
  describe "#perform" do
    let(:upload) { create(:partnership_csv_upload, :with_csv) }

    let(:perform) do
      SyncPartnershipCsvUploadJob
        .perform_now(partnership_csv_upload_id: upload.id)
    end

    it "writes the CSV content to the uploaded_urns field" do
      expect(upload.uploaded_urns).to be_nil

      perform

      expect(upload.reload.uploaded_urns).to eql(upload.csv.download.lines(chomp: true))
    end
  end
end
