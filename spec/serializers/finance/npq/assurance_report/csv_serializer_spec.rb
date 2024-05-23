# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::NPQ::AssuranceReport::CsvSerializer do
  let(:record) { build_record }

  describe "attributes" do
    let(:records) { [record] }
    subject { described_class.new(records, double) }

    let(:rows) { subject.call.split("\n") }
    let(:header) { rows.first.split(",") }
    let(:data) { rows.second.split(",") }

    it "includes all attributes in the row" do
      expect(data).to match_array(
        [
          "123",
          "John Doe",
          "TRN123",
          "course-id-123",
          "schedule-123",
          "eligible-true",
          "provider-name",
          "school-urn",
          "school-name",
          "active",
          "active-reason",
          "declaration-id-123",
          "submitted",
          "started",
          "2022-02-01T12:00:00Z",
          "2022-01-01T12:00:00Z",
          "statement-name",
          "satement-id-123",
          "target-delivery-funding",
        ],
      )
    end

    describe "csv_headers" do
      let(:expected_header) do
        [
          "Participant ID",
          "Participant Name",
          "TRN",
          "Course Identifier",
          "Schedule",
          "Eligible For Funding",
          "Lead Provider Name",
          "School Urn",
          "School Name",
          "Training Status",
          "Training Status Reason",
          "Declaration ID",
          "Declaration Status",
          "Declaration Type",
          "Declaration Date",
          "Declaration Created At",
          "Statement Name",
          "Statement ID",
          "Targeted Delivery Funding",
        ]
      end

      context "when `npq_capping` Feature Flag is active" do
        before { FeatureFlag.activate(:npq_capping) }

        it "does not include Funded place" do
          expected_header.insert(6, "Funded place")

          expect(header).to eq(expected_header)
        end
      end

      context "when `npq_capping` Feature Flag is not active" do
        before { FeatureFlag.deactivate(:npq_capping) }

        it "includes Funded place" do
          expect(header).to eq(expected_header)
        end
      end
    end

    describe "`funded_place attribute" do
      context "when `npq_capping` Feature Flag is active" do
        before { FeatureFlag.activate(:npq_capping) }

        it "includes `funded_place`" do
          expect(rows.second).to include("funded-true")
        end
      end

      context "when `npq_capping` Feature Flag is not active" do
        before { FeatureFlag.deactivate(:npq_capping) }

        it "does not include Funded place" do
          expect(rows.second).to_not include("funded-true")
        end
      end
    end
  end

  def build_record
    double(
      participant_id: "123",
      participant_name: "John Doe",
      trn: "TRN123",
      course_identifier: "course-id-123",
      schedule: "schedule-123",
      eligible_for_funding: "eligible-true",
      funded_place: "funded-true",
      npq_lead_provider_name: "provider-name",
      school_urn: "school-urn",
      school_name: "school-name",
      training_status: "active",
      training_status_reason: "active-reason",
      declaration_id: "declaration-id-123",
      declaration_status: "submitted",
      declaration_type: "started",
      declaration_date: Time.zone.local(2022, 2, 1, 12, 0, 0),
      declaration_created_at: Time.zone.local(2022, 1, 1, 12, 0, 0),
      statement_name: "statement-name",
      statement_id: "satement-id-123",
      targeted_delivery_funding: "target-delivery-funding",
    )
  end
end
