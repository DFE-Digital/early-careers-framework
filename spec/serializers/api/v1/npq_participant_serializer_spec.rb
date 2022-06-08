# frozen_string_literal: true

require "rails_helper"

module Api
  module V1
    RSpec.describe NPQParticipantSerializer do
      describe "serialization" do
        let(:participant) { create(:user) }

        describe "multiple providers" do
          let!(:schedule) { create(:npq_leadership_schedule) }
          let!(:participant) { create(:user) }
          let!(:identity) { create(:participant_identity, user: participant) }

          let(:cpd_provider_one) { create(:cpd_lead_provider) }
          let(:cpd_provider_two) { create(:cpd_lead_provider) }
          let(:provider_one) { create(:npq_lead_provider, cpd_lead_provider: cpd_provider_one) }
          let(:provider_two) { create(:npq_lead_provider, cpd_lead_provider: cpd_provider_two) }
          let(:course_one) { create(:npq_course, identifier: "npq-headship") }
          let(:course_two) { create(:npq_course, identifier: "npq-senior-leadership") }

          let!(:application_one) { create(:npq_application, :accepted, npq_lead_provider: provider_one, npq_course: course_one, participant_identity: identity) }
          let!(:application_two) { create(:npq_application, :accepted, npq_lead_provider: provider_two, npq_course: course_two, participant_identity: identity) }

          it "does not leak course info when given a provider param" do
            result = NPQParticipantSerializer.new(participant, params: { cpd_lead_provider: provider_one.cpd_lead_provider }).serializable_hash
            expect(result[:data][:attributes][:npq_courses]).to eq %w[npq-headship]
          end

          it "does not leak course info when given no provider param" do
            result = NPQParticipantSerializer.new(participant).serializable_hash
            expect(result[:data][:attributes][:npq_courses]).to eq []
          end
        end

        it "includes updated_at" do
          result = NPQParticipantSerializer.new(participant).serializable_hash
          expect(result[:data][:attributes][:updated_at]).to eq participant.updated_at.rfc3339
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
