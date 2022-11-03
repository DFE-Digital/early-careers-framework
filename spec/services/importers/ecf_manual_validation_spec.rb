# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe Importers::ECFManualValidation do
  let(:example_csv_file) { file_fixture "example_ecf_manual_validation.csv" }

  subject(:importer) { described_class }

  describe ".call" do
    context "when participants exist" do
      before do
        users = []
        CSV.read(example_csv_file, headers: true).each { |row| users << create(:user, id: row["id"], full_name: row["name"]) }
        users.each do |user|
          tp = create(:teacher_profile, user:)
          create(:ect_participant_profile, teacher_profile: tp)
        end

        allow(Participants::ParticipantValidationForm).to receive(:call).exactly(6).times
      end

      it "calls the validation service for each participant" do
        importer.call(path_to_csv: example_csv_file)
      end

      it "handles bad or empty dates" do
        expect {
          importer.call(path_to_csv: example_csv_file)
        }.not_to raise_error
      end
    end

    context "when matching participants do not exist" do
      it "does not call the validation service" do
        expect(Participants::ParticipantValidationForm).not_to receive(:call)
        importer.call(path_to_csv: example_csv_file)
      end
    end
  end
end
