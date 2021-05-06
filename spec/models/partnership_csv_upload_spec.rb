# frozen_string_literal: true

require "rails_helper"

RSpec.describe PartnershipCsvUpload, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:lead_provider).optional }
    it { is_expected.to belong_to(:delivery_partner).optional }
  end

  describe "relations" do
    it { is_expected.to have_one(:csv_attachment) }
  end

  describe "csv_validation" do
    let(:csv_upload) { build(:partnership_csv_upload, :with_csv) }
    let(:text_upload) { build(:partnership_csv_upload, :with_text) }

    context "when CSV file is too large" do
      before do
        allow(csv_upload.csv)
        .to receive(:byte_size).and_return 3.megabytes
      end

      it "is invalid" do
        expect(csv_upload).to be_invalid
      end
    end

    context "when file extension is not csv" do
      it "is invalid" do
        expect(text_upload).to be_invalid
      end
    end
  end
end
