# frozen_string_literal: true

require "rails_helper"

RSpec.describe Importers::NPQManualValidation do
  let(:npq_validation_data) { create(:npq_validation_data) }
  let(:file) { Tempfile.new("test.csv") }

  before do
    Finance::Schedule.find_or_create_by!(name: "ECF September standard 2021")
    NPQ::CreateOrUpdateProfile.new(npq_validation_data: npq_validation_data).call
  end

  around do |example|
    original_stdout = $stdout
    $stdout = File.open(File::NULL, "w")

    example.run

    $stdout = original_stdout
  end

  describe "#call" do
    subject do
      described_class.new(path_to_csv: file.path)
    end

    context "with well formed csv" do
      before do
        file.write("application_ecf_id,validated_trn")
        file.write("\n")
        file.write("123,7654321")
        file.write("\n")
        file.write("#{npq_validation_data.id},7654321")
        file.rewind
      end

      it "updates trn" do
        expect {
          subject.call
        }.to change { npq_validation_data.reload.teacher_reference_number }.to("7654321")
      end

      it "updates teacher_reference_number_verified to true" do
        expect {
          subject.call
        }.to change { npq_validation_data.reload.teacher_reference_number_verified }.to(true)
      end

      it "updates TRN on teacher profile" do
        expect {
          subject.call
        }.to change { npq_validation_data.reload.user.teacher_profile.trn }.from(nil).to("7654321")
      end
    end

    context "with malformed csv" do
      before do
        file.write("application_id,trn")
        file.write("\n")
        file.rewind
      end

      it "raises error" do
        expect {
          subject.call
        }.to raise_error(NameError)
      end
    end
  end
end
