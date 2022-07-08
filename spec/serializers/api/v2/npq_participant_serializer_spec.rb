# frozen_string_literal: true

require "rails_helper"

module Api
  module V2
    RSpec.describe NPQParticipantSerializer do
      describe "serialization" do
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
            let(:second_profile) do
              create(
                :npq_participant_profile,
                teacher_profile: user.teacher_profile,
              )
            end

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

        context "when training_status is withdrawn" do
          let(:participant) { profile.user }
          let(:profile) { create(:npq_participant_profile, training_status: "withdrawn") }
          let(:npq_application) { profile.npq_application }
          let(:cpd_lead_provider) { npq_application.npq_lead_provider.cpd_lead_provider }

          subject { described_class.new(participant, params: { cpd_lead_provider: }) }

          it "nullifies email" do
            expect(subject.serializable_hash.dig(:data, :attributes, :email)).to be_nil
          end
        end

        context "when 2 NPQ profiles with same provider where 1 is withdrawn" do
          let(:participant1) { profile1.user }
          let(:profile1) { create(:npq_participant_profile, training_status: "withdrawn") }
          let(:npq_application1) { profile1.npq_application }
          let(:npq_lead_provider1) { npq_application1.npq_lead_provider }
          let(:cpd_lead_provider1) { npq_lead_provider1.cpd_lead_provider }

          let!(:profile2) { create(:npq_participant_profile, training_status: "active", teacher_profile: participant1.teacher_profile) }

          before do
            profile2.npq_application.update(npq_lead_provider: npq_lead_provider1)
          end

          subject { described_class.new(participant1, params: { cpd_lead_provider: cpd_lead_provider1 }) }

          it "does not nullify email" do
            expect(subject.serializable_hash.dig(:data, :attributes, :email)).to be_present
          end
        end
      end
    end
  end
end
