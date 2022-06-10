# frozen_string_literal: true

require "rails_helper"

module Api
  module V2
    RSpec.describe NPQParticipantSerializer do
      describe "serialization", :with_default_schedules do
        let(:participant) { create(:user) }

        it "includes updated_at" do
          result = NPQParticipantSerializer.new(participant).serializable_hash
          expect(result[:data][:attributes][:updated_at]).to eq participant.updated_at.rfc3339
        end

        describe "npq_enrolments" do
          let(:user) { profile.user }
          let(:profile) { create(:npq_participant_profile, school_urn: "123456") }

          it "returns expected data", :aggregate_failures do
            result = NPQParticipantSerializer.new(user).serializable_hash

            expect(result[:data][:attributes][:npq_enrolments][0][:course_identifier]).to eql(profile.npq_course.identifier)
            expect(result[:data][:attributes][:npq_enrolments][0][:schedule_identifier]).to eql(profile.schedule.schedule_identifier)
            expect(result[:data][:attributes][:npq_enrolments][0][:cohort]).to eql(profile.schedule.cohort.start_year.to_s)
            expect(result[:data][:attributes][:npq_enrolments][0][:npq_application_id]).to eql(profile.npq_application.id)
            expect(result[:data][:attributes][:npq_enrolments][0][:eligible_for_funding]).to eql(profile.npq_application.eligible_for_funding)
            expect(result[:data][:attributes][:npq_enrolments][0][:training_status]).to eql(profile.training_status)
            expect(result[:data][:attributes][:npq_enrolments][0][:school_urn]).to eql(profile.school_urn)
            expect(result[:data][:attributes][:npq_enrolments][0][:targeted_delivery_funding_eligibility]).to eql(profile.npq_application.targeted_delivery_funding_eligibility)
          end

          context "when there are multiple providers involved" do
            let(:second_profile) { create(:npq_participant_profile, user:) }

            before do
              profile
              second_profile
            end

            it "only includes enrolments from the querying provider" do
              querying_cpd_lead_provider = profile.npq_application.npq_lead_provider.cpd_lead_provider

              result = NPQParticipantSerializer.new(user, params: { cpd_lead_provider: querying_cpd_lead_provider }).serializable_hash

              expect(result[:data][:attributes][:npq_enrolments].size).to be(1)
            end
          end
        end
      end
    end
  end
end
