# frozen_string_literal: true

require "rails_helper"

module Api
  module V1
    RSpec.describe NPQApplicationSerializer do
      describe "serialization" do
        let(:npq_application) { create(:npq_application, targeted_delivery_funding_eligibility: true) }

        it "returns expected data" do
          result = NPQApplicationSerializer.new(npq_application).serializable_hash

          expect(result[:data][:attributes][:course_identifier]).to eql(npq_application.npq_course.identifier)
          expect(result[:data][:attributes][:email]).to eql(npq_application.participant_identity.email)
          expect(result[:data][:attributes][:email_validated]).to eql(true)
          expect(result[:data][:attributes][:employer_name]).to eql(npq_application.employer_name)
          expect(result[:data][:attributes][:employment_role]).to eql(npq_application.employment_role)
          expect(result[:data][:attributes][:full_name]).to eql(npq_application.participant_identity.user.full_name)
          expect(result[:data][:attributes][:funding_choice]).to eql(npq_application.funding_choice)
          expect(result[:data][:attributes][:headteacher_status]).to eql(npq_application.headteacher_status)
          expect(result[:data][:attributes][:ineligible_for_funding_reason]).to eql(npq_application.ineligible_for_funding_reason)
          expect(result[:data][:attributes][:participant_id]).to eql(npq_application.participant_identity.external_identifier)
          expect(result[:data][:attributes][:private_childcare_provider_urn]).to eql(npq_application.private_childcare_provider_urn)
          expect(result[:data][:attributes][:teacher_reference_number]).to eql(npq_application.teacher_reference_number)
          expect(result[:data][:attributes][:teacher_reference_number_validated]).to eql(npq_application.teacher_reference_number_verified)
          expect(result[:data][:attributes][:school_urn]).to eql(npq_application.school_urn)
          expect(result[:data][:attributes][:school_ukprn]).to eql(npq_application.school_ukprn)
          expect(result[:data][:attributes][:status]).to eql(npq_application.lead_provider_approval_status)
          expect(result[:data][:attributes][:works_in_school]).to eql(npq_application.works_in_school)
          expect(result[:data][:attributes][:eligible_for_funding]).to eql(npq_application.eligible_for_dfe_funding)
          expect(result[:data][:attributes][:targeted_delivery_funding_eligibility]).to eql(npq_application.targeted_delivery_funding_eligibility)

          expect(result[:data][:attributes][:teacher_catchment]).to eq(npq_application.teacher_catchment.present?)
          expect(result[:data][:attributes][:teacher_catchment_country]).to eq(npq_application.teacher_catchment_country)
          expect(result[:data][:attributes][:teacher_catchment_iso_country_code]).to eq(npq_application.teacher_catchment_iso_country_code)
          expect(result[:data][:attributes][:itt_provider]).to eql(npq_application.itt_provider)
          expect(result[:data][:attributes][:lead_mentor]).to eql(npq_application.lead_mentor)
        end
      end
    end
  end
end
