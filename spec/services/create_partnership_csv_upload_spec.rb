# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreatePartnershipCsvUpload do
  let(:cohort_id) { create(:cohort).id }
  let(:delivery_partner_id) { create(:delivery_partner).id }
  let(:lead_provider_id) { create(:lead_provider).id }
  let(:urns) { %w[111 222] }
  let(:csv_file) { given_the_csv_contains_urns(urns, insert_bom: true) }

  subject do
    described_class.new(
      csv_file:,
      cohort_id:,
      lead_provider_id:,
      delivery_partner_id:,
    )
  end

  describe ".call" do
    it "creates a partnership csv upload with supplied parameters" do
      expect { subject.call }.to change(PartnershipCsvUpload, :count).by(1)
    end

    it "sets the correct urns on the partnership csv upload from the file" do
      expect(subject.call.urns).to eq(urns)
    end

    it "sets the correct attributes on the partnership csv upload" do
      expect(subject.call.attributes.symbolize_keys).to include(
        cohort_id:,
        lead_provider_id:,
        delivery_partner_id:,
      )
    end

    context "with duplicate urns" do
      let(:urns) { %w[1 1 2 2 3] }

      it "populates the uploaded_urns field with the CSV contents and maintains duplicates" do
        expect(subject.call.uploaded_urns).to eq(urns.map(&:to_s))
      end
    end

    context "with empty urns" do
      let(:urns) { ["1", "", "2", " ", "3", "4"] }

      it "removes empty urns from uploaded_urns" do
        expect(subject.call.uploaded_urns).to eq(%w[1 2 3 4])
      end
    end

    context "with urns on one line" do
      let(:urns) { ["1", "2,3,4", "5", ",,,", "6", "7"] }

      it "flattens multiple urns on one line" do
        expect(subject.call.uploaded_urns).to eql(%w[1 2 3 4 5 6 7])
      end
    end

    context "with whitespaces" do
      let(:urns) { ["1", "2,3 ,4 ", "5", " ,,,", "6", "7"] }

      it "removes leading or trailing whitespace and condenses internal whitespace" do
        expect(subject.call.uploaded_urns).to eql(%w[1 2 3 4 5 6 7])
      end
    end

    context "with other unicode characters" do
      let(:urns) { ["\u00A0 ", " 18900\u000f", "  10000\u00A0 \255", "\u2000", " 12345\n"] }

      it "removes extra characters and keeps the urns" do
        expect(subject.call.uploaded_urns).to eql(%w[18900 10000 12345])
      end
    end
  end

private

  def given_the_csv_contains_urns(urns, insert_bom: false)
    bom = "\xEF\xBB\xBF"

    file = Tempfile.new
    file.write(bom) if insert_bom
    file.write(urns.join("\n"))
    file.rewind

    file
  ensure
    file&.unlink
  end
end
