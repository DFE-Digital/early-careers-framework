# frozen_string_literal: true

require "tempfile"

RSpec.describe Importers::CreateNPQCourse do
  let(:csv) { Tempfile.new("data.csv") }
  let(:path_to_csv) { csv.path }

  subject(:importer) { described_class.new(path_to_csv:) }

  describe "#call" do
    context "with new npq_courses" do
      before do
        csv.write "name,identifier"
        csv.write "\n"
        csv.write "NPQ Leading Teaching (NPQLT),npq-leading-teaching, "
        csv.write "\n"
        csv.write "NPQ for Senior Leadership (NPQSL),npq-senior-leadership,"
        csv.write "\n"
        csv.write "NPQ for Leading Primary Mathematics (NPQLPM),npq-leading-primary-mathematics,"
        csv.write "\n"
        csv.write "NPQ for Headship (NPQH),npq-headship,"
        csv.write "\n"
        csv.close
      end

      it "creates npq_course records" do
        expect { importer.call }.to change { NPQCourse.count }.by(4)
      end

      it "sets the correct identifier on the record" do
        importer.call

        course = NPQCourse.find_by(name: "NPQ Leading Teaching (NPQLT)")
        expect(course.identifier).to eq "npq-leading-teaching"
      end
    end
  end
end
