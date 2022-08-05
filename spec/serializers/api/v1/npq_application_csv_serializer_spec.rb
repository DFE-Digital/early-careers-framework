# frozen_string_literal: true

require "rails_helper"

module Api
  module V1
    RSpec.describe NPQApplicationCsvSerializer do
      describe "serialization" do
        let(:npq_application) { create(:npq_application, targeted_delivery_funding_eligibility: true) }

        it "returns expected data", :aggregate_failures do
          string = NPQApplicationCsvSerializer.new([npq_application]).call

          rows = CSV.parse(string, headers: true)

          expect(rows[0]["course_identifier"]).to eql(npq_application.npq_course.identifier)
          expect(rows[0]["email"]).to eql(npq_application.participant_identity.email)
          expect(rows[0]["email_validated"]).to eql("true")
          expect(rows[0]["employer_name"]).to eql(npq_application.employer_name)
          expect(rows[0]["employment_role"]).to eql(npq_application.employment_role)
          expect(rows[0]["full_name"]).to eql(npq_application.participant_identity.user.full_name)
          expect(rows[0]["funding_choice"]).to eql(npq_application.funding_choice)
          expect(rows[0]["headteacher_status"]).to eql(npq_application.headteacher_status)
          expect(rows[0]["ineligible_for_funding_reason"]).to eql(npq_application.ineligible_for_funding_reason)
          expect(rows[0]["participant_id"]).to eql(npq_application.participant_identity.external_identifier)
          expect(rows[0]["private_childcare_provider_urn"]).to eql(npq_application.private_childcare_provider_urn)
          expect(rows[0]["teacher_reference_number"]).to eql(npq_application.teacher_reference_number)
          expect(rows[0]["teacher_reference_number_validated"]).to eql(npq_application.teacher_reference_number_verified.to_s)
          expect(rows[0]["school_urn"]).to eql(npq_application.school_urn)
          expect(rows[0]["school_ukprn"]).to eql(npq_application.school_ukprn)
          expect(rows[0]["status"]).to eql(npq_application.lead_provider_approval_status)
          expect(rows[0]["works_in_school"]).to eql(npq_application.works_in_school.to_s)
          expect(rows[0]["eligible_for_funding"]).to eql(npq_application.eligible_for_dfe_funding.to_s)
          expect(rows[0]["targeted_delivery_funding_eligibility"]).to eql(npq_application.targeted_delivery_funding_eligibility.to_s)
        end
      end
    end
  end
end
