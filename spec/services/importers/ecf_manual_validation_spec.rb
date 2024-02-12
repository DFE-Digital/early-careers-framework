# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe Importers::ECFManualValidation do
  let(:example_csv_file) { file_fixture "example_ecf_manual_validation.csv" }

  subject(:importer) { described_class }

  describe ".call" do
    before { allow(Participants::ParticipantValidationForm).to receive(:call) }

    subject(:call) { importer.call(path_to_csv: example_csv_file) }

    context "when participants exist" do
      let!(:existing_users) do
        CSV.read(example_csv_file, headers: true).map do |row|
          create(:user, id: row["id"], full_name: row["name"]).tap { |user| create(:ect, :eligible_for_funding, user:) }
        end
      end

      it "calls the validation service for each participant" do
        expect(Participants::ParticipantValidationForm).to receive(:call).exactly(existing_users.size).times
        call
      end

      it "handles bad or empty dates" do
        expect { call }.not_to raise_error
      end

      it "clears the teacher profile trns" do
        expect(existing_users.map { |u| u.teacher_profile.trn }).to all(be_present)
        call
        expect(existing_users.map { |u| u.teacher_profile.reload.trn }).to all(be_nil)
      end

      it "does not clear the trn when an NPQ profile is present" do
        user = existing_users.first
        create(:npq_participant_profile, user:)

        expect { call }.not_to change { user.teacher_profile.reload.trn }
      end

      it "does not clear the trn when a participant profile has declarations" do
        user = existing_users.first
        participant_profile = user.participant_profiles.first
        cpd_lead_provider = participant_profile.lead_provider.cpd_lead_provider
        create(:ect_participant_declaration, participant_profile:, cpd_lead_provider:)

        expect { call }.not_to change { participant_profile.teacher_profile.reload.trn }
      end
    end

    context "when matching participants do not exist" do
      it "does not call the validation service" do
        expect(Participants::ParticipantValidationForm).not_to receive(:call)
        call
      end
    end
  end
end
