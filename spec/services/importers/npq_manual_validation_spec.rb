# frozen_string_literal: true

require "rails_helper"

RSpec.describe Importers::NPQManualValidation do
  let(:npq_course)       { create(:npq_course, identifier: "npq-senior-leadership") }
  let(:npq_application)  { create(:npq_application, :accepted, npq_course:, teacher_reference_number_verified: false) }
  let(:file)             { Tempfile.new("test.csv") }
  let!(:teacher_profile) { npq_application.profile.teacher_profile }
  let(:teacher_reference_number) { "7654321" }

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
        file.write("#{npq_application.id},#{teacher_reference_number}")
        file.rewind
      end

      it "updates trn" do
        expect {
          subject.call
        }.to change { npq_application.reload.teacher_reference_number }.to("7654321")
      end

      it "updates the teacher profile trn" do
        expect {
          subject.call
        }.to change { teacher_profile.reload.trn }.to("7654321")
      end

      it "updates teacher_reference_number_verified to true" do
        expect {
          subject.call
        }.to change { npq_application.reload.teacher_reference_number_verified }.to(true)
      end

      context "when application trn is less than 7 digits" do
        let(:teacher_reference_number) { "123456" }

        it "adds leading zero" do
          expect {
            subject.call
          }.to change { npq_application.reload.teacher_reference_number }.to("0123456")
        end
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
