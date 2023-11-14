# frozen_string_literal: true

require "tempfile"

RSpec.describe Importers::ReconcilationDataImporter do
  describe "#call" do
    let(:profile1) { FactoryBot.create(:npq_participant_profile) }
    let(:profile2) { FactoryBot.create(:npq_participant_profile) }
    let(:user1)    { profile1.user }
    let(:user2)    { profile2.user }

    let(:path_to_csv) do
      csv = Tempfile.new("reconcile_csv_data.csv")
      csv.write "participant_id 1,participant_id 2"
      csv.write "\n"
      csv.write "#{user1.id},#{user2.id}"
      csv.write "\n"
      csv.close
      csv.path
    end

    subject do
      described_class.new(path_to_csv:)
    end

    context "with valid CSV data" do
      it "transfers data between users" do
        expect { subject.call }.to change {
                                     [
                                       user1.reload.npq_applications.count,
                                       user1.reload.participant_identities.count,
                                       user1.reload.participant_profiles.count,
                                       user2.reload.npq_applications.count,
                                       user2.reload.participant_identities.count,
                                       user2.reload.participant_profiles.count,
                                     ]
                                   }
      end
    end

    context "with missing headers in CSV" do
      let(:path_to_csv) do
        csv = Tempfile.new("reconcile_csv_data.csv")
        csv.write "participant_id 1"
        csv.write "\n"
        csv.write user1.id.to_s
        csv.write "\n"
        csv.close
        csv.path
      end

      it "raises an error for missing headers" do
        expect { subject.call }.to raise_error(NameError, "Invalid headers")
      end
    end

    context "with missing user data in CSV" do
      let(:path_to_csv) do
        csv = Tempfile.new("reconcile_csv_data.csv")
        csv.write "participant_id 1,participant_id 2"
        csv.write "\n"
        csv.write "#{user1.id},invalid_user_id"
        csv.write "\n"
        csv.close
        csv.path
      end

      it "logs a message about missing user data" do
        logs = []
        allow(Rails.logger).to receive(:info) { |message| logs << message }
        subject.call
        expect(logs).to include(/Data is not updated because user data is not present/)
      end
    end
  end
end
