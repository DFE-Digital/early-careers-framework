# frozen_string_literal: true

require "rails_helper"

RSpec.describe PartnershipCsvUpload, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:lead_provider).optional }
  end

  describe "relations" do
    it { is_expected.to have_one(:csv_attachment) }
  end

  describe "csv_validation" do
    subject { build(:partnership_csv_upload, :with_csv) }

    context "when CSV file is too large" do
      before do
        allow(subject.csv)
        .to receive(:byte_size).and_return 3.megabytes
      end

      it do
        is_expected.to be_invalid
      end
    end

    context "when file is not type text/csv" do
      before do
        allow(subject.csv)
        .to receive(:content_type).and_return("text/plain")
      end

      it do
        is_expected.to be_invalid
      end
    end
  end
end
