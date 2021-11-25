# frozen_string_literal: true

require "rails_helper"

RSpec.describe Importers::NPQManualValidation do
  let(:npq_course) { create(:npq_course, identifier: "npq-senior-leadership") }
  let(:npq_application) { create(:npq_application, npq_course: npq_course) }
  let(:file) { Tempfile.new("test.csv") }

  before do
    create(:npq_leadership_schedule)
    NPQ::Accept.new(npq_application: npq_application).call
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
        file.write("#{npq_application.id},7654321")
        file.rewind
      end

      it "updates trn" do
        expect {
          subject.call
        }.to change { npq_application.reload.teacher_reference_number }.to("7654321")
      end

      it "updates teacher_reference_number_verified to true" do
        expect {
          subject.call
        }.to change { npq_application.reload.teacher_reference_number_verified }.to(true)
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
