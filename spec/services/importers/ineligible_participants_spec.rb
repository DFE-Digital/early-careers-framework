# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe Importers::IneligibleParticipants do
  let(:csv_file) { file_fixture "ineligible_participants.csv" }
  subject(:service) { described_class }

  describe ".call" do
    before do
      service.call(path_to_csv: csv_file, reason: "previous_participant")
    end

    it "adds inelgible participant records from the file" do
      expect(ECFIneligibleParticipant.count).to be 3
    end

    it "sets the reason for the ineligibility" do
      expect(ECFIneligibleParticipant.previous_participant.count).to be 3
    end

    it "only populates the TRN field when the TRN is present in the file" do
      record = ECFIneligibleParticipant.find_by(trn: "9876543")
      expect(record.full_name).to be_nil
      expect(record.date_of_birth).to be_nil
      expect(record.urn).to be_nil
    end

    it "does not duplicate records given the same information" do
      expect {
        service.call(path_to_csv: csv_file, reason: "previous_participant")
      }.not_to change { ECFIneligibleParticipant.count }
    end

    context "when trn is not present" do
      it "populates full_name and either/both of date_of_birth and urn" do
        record = ECFIneligibleParticipant.find_by(full_name: "Sally Smith")
        expect(record.trn).to be_nil
        expect(record.date_of_birth).to be_nil
        expect(record.urn).to eq "145091"
      end

      context "when name is not present" do
        it "does not create a record" do
          expect(ECFIneligibleParticipant.find_by(urn: "132132")).to be_nil
          expect(ECFIneligibleParticipant.find_by(urn: "141333")).to be_nil
        end
      end

      context "when only name is present" do
        it "does not create a record" do
          expect(ECFIneligibleParticipant.find_by(full_name: "Walter Ponds")).to be_nil
        end
      end
    end
  end
end
