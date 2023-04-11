# frozen_string_literal: true

require "rails_helper"

module Api
  module V3
    RSpec.describe NPQParticipantSerializer do
      describe "serialization", :with_default_schedules do
        let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
        let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }
        let(:user) { create(:user) }
        let!(:profile) { create(:npq_participant_profile, user:, npq_lead_provider:) }
        let!(:participant) { profile.user }

        subject { described_class.new([participant], params: { cpd_lead_provider: }) }

        it "returns the expected data" do
          result = subject.serializable_hash

          expect(result[:data]).to match_array([
            id: participant.id,
            type: :'npq-participant',
            attributes: {
              full_name: profile.user.full_name,
              teacher_reference_number: participant.teacher_profile.trn,
              updated_at: profile.user.updated_at.rfc3339,
              npq_enrolments: [{
                email: profile.user.email,
                course_identifier: profile.npq_course.identifier,
                schedule_identifier: profile.schedule.schedule_identifier,
                cohort: profile.schedule.cohort.start_year.to_s,
                npq_application_id: profile.npq_application.id,
                eligible_for_funding: profile.npq_application.eligible_for_funding,
                training_status: profile.training_status,
                school_urn: profile.school_urn,
                targeted_delivery_funding_eligibility: profile.npq_application.targeted_delivery_funding_eligibility,
                created_at: profile.created_at.rfc3339,
              }],
            },
          ])
        end

        describe "npq_enrolments" do
          context "when there are multiple providers involved" do
            let(:another_cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
            let(:another_npq_lead_provider) { another_cpd_lead_provider.npq_lead_provider }
            let!(:second_profile) { create(:npq_participant_profile, user:, npq_lead_provider: another_npq_lead_provider) }

            it "only includes enrolments from the querying provider" do
              result = subject.serializable_hash

              expect(result[:data][0][:attributes][:npq_enrolments].size).to be(1)
            end
          end

          context "when the profile is withdrawn" do
            let!(:profile) { create(:npq_participant_profile, :withdrawn, user:, npq_lead_provider:) }

            it "includes a withdrawal object" do
              result = subject.serializable_hash

              expect(result[:data][0][:attributes][:npq_enrolments][0][:withdrawal]).to eq({
                reason: profile.participant_profile_state.reason,
                date: profile.participant_profile_state.created_at.rfc3339,
              })
            end

            it "does not include a deferral object" do
              result = subject.serializable_hash

              expect(result[:data][0][:attributes][:npq_enrolments][0][:deferral]).to be_nil
            end
          end

          context "when the profile is deferred" do
            let!(:profile) { create(:npq_participant_profile, :deferred, user:, npq_lead_provider:) }

            it "includes a deferral object" do
              result = subject.serializable_hash

              expect(result[:data][0][:attributes][:npq_enrolments][0][:deferral]).to eq({
                reason: profile.participant_profile_state.reason,
                date: profile.participant_profile_state.created_at.rfc3339,
              })
            end

            it "does not include a withdrawal object" do
              result = subject.serializable_hash

              expect(result[:data][0][:attributes][:npq_enrolments][0][:withdrawal]).to be_nil
            end
          end

          it "does not include a withdrawal object" do
            result = subject.serializable_hash

            expect(result[:data][0][:attributes][:npq_enrolments][0][:withdrawal]).to be_nil
          end

          it "does not include a deferral object" do
            result = subject.serializable_hash

            expect(result[:data][0][:attributes][:npq_enrolments][0][:deferral]).to be_nil
          end
        end
      end
    end
  end
end
