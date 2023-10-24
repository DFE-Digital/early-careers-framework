# frozen_string_literal: true

require "tempfile"

RSpec.describe Importers::CreateNewNPQCourse do
  describe "#call" do
    let(:start_year) { Cohort.ordered_by_start_year.last.start_year }

    let!(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider, name: "Koala Institute") }
    let!(:npq_course) { create(:npq_course, identifier: "npq-leading-primary-mathematics") }

    let(:npq_course_csv) do
      csv = Tempfile.new("npq_course_csv_data.csv")
      csv.write "name,identifier"
      csv.write "\n"
      csv.write "#{npq_course.name},#{npq_course.identifier},"
      csv.write "\n"
      csv.close
      csv.path
    end

    let(:contract_csv) do
      csv = Tempfile.new("contract_csv_data.csv")
      csv.write "provider_name,cohort_year,course_identifier,recruitment_target,per_participant,service_fee_installments,special_course"
      csv.write "\n"
      csv.write "#{cpd_lead_provider.name},#{start_year},npq-leading-primary-mathematics,321,654.87,14,FALSE"
      csv.write "\n"
      csv.close
      csv.path
    end

    subject do
      described_class.new(npq_course_csv:, contract_csv:)
    end

    context "create new Course" do
      it "creates course" do
        subject.call
        expect(NPQCourse.count).to eql(1)
      end

      it "creates npq contract" do
        expect(NPQContract.count).to eql(0)
        subject.call
        expect(NPQContract.count).to eql(1)
        expect(NPQContract.first.course_identifier).to eql("npq-leading-primary-mathematics")
      end
    end
  end
end
