# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe Importers::IneligibleParticipants do
  let(:csv_file) { file_fixture "ineligible_participants.csv" }
  subject(:service) { described_class }

  describe ".call" do
    before do
      service.call(path_to_csv: csv_file, reason: "previous_participation")
    end

    context "when the trn field is present" do
      it "adds inelgible participant records from the file" do
        expect(ECFIneligibleParticipant.find_by(trn: "1234567")).to be_present
        expect(ECFIneligibleParticipant.find_by(trn: "9876543")).to be_present
        expect(ECFIneligibleParticipant.find_by(trn: "4488331")).to be_present
        expect(ECFIneligibleParticipant.count).to be 3
      end

      it "sets the reason for the ineligibility" do
        expect(ECFIneligibleParticipant.previous_participation.count).to be 3
      end

      context "when the trn already exists" do
        it "does not create a duplicate record" do
          expect {
            service.call(path_to_csv: csv_file, reason: "previous_participation")
          }.not_to change { ECFIneligibleParticipant.count }
        end

        context "when the reason is different" do
          before do
            @both_types = ECFIneligibleParticipant.find_by(trn: "4488331")
            @both_types.previous_induction!
          end

          it "updates the reason to previous_induction_and_participation" do
            service.call(path_to_csv: csv_file, reason: "previous_participation")
            expect(@both_types.reload).to be_previous_induction_and_participation
          end
        end
      end
    end
  end
end
