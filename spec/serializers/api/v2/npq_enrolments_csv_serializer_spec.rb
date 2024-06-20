# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::NPQEnrolmentsCsvSerializer do
  let(:npq_application) do
    create(:npq_application,
           :accepted,
           eligible_for_funding: true,
           npq_course:,
           npq_lead_provider:)
  end
  let(:npq_lead_provider) { create(:npq_lead_provider) }
  let(:npq_course) { create(:npq_leadership_course, identifier: "npq-senior-leadership") }
  let(:funding_cap) { 10 }
  let!(:statement) do
    create(
      :npq_statement,
      :next_output_fee,
      cpd_lead_provider: npq_lead_provider.cpd_lead_provider,
      cohort: npq_application.cohort,
    )
  end
  let!(:npq_contract) do
    create(
      :npq_contract,
      npq_lead_provider:,
      cohort: statement.cohort,
      course_identifier: npq_course.identifier,
      version: statement.contract_version,
      funding_cap:,
    )
  end

  let(:participant_profile) { npq_application.profile }
  subject { described_class.new(scope: [participant_profile]).call }

  describe "serialization" do
    let(:rows) { CSV.parse(subject, headers: true) }

    describe "funded_place" do
      context "when Feature Flag `npq_capping` is active" do
        before { FeatureFlag.activate(:npq_capping) }

        it "returns funded place" do
          npq_application.update!(funded_place: true)

          expect(rows[0]["funded_place"]).to eql("true")
        end
      end

      context "when Feature Flag `npq_capping` is inactive" do
        before { FeatureFlag.deactivate(:npq_capping) }

        it "does not return funded place attribute" do
          expect(rows[0]).to_not include("funded_place")
        end
      end
    end
  end
end
