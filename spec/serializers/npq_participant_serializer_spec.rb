# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQParticipantSerializer do
  describe "serialization" do
    describe "multiple providers" do
      let!(:schedule) { create(:npq_specialist_schedule) }
      let!(:participant) { create(:user) }

      let!(:cpd_provider_one) { create(:cpd_lead_provider) }
      let!(:cpd_provider_two) { create(:cpd_lead_provider) }
      let!(:provider_one) { create(:npq_lead_provider, cpd_lead_provider: cpd_provider_one) }
      let!(:provider_two) { create(:npq_lead_provider, cpd_lead_provider: cpd_provider_two) }
      let!(:course_one) { create(:npq_course, identifier: "npq-headship") }
      let!(:course_two) { create(:npq_course, identifier: "npq-senior-leadership") }

      let!(:application_one) { create(:npq_application, :accepted, npq_lead_provider: provider_one, npq_course: course_one, user: participant) }
      let!(:application_two) { create(:npq_application, :accepted, npq_lead_provider: provider_two, npq_course: course_two, user: participant) }

      it "does not leak course info when given a provider param" do
        result = NPQParticipantSerializer.new(participant, params: { cpd_lead_provider: provider_one.cpd_lead_provider }).serializable_hash
        expect(result[:data][:attributes][:npq_courses]).to eq %w[npq-headship]
      end

      it "does not leak course info when given no provider param" do
        result = NPQParticipantSerializer.new(participant).serializable_hash
        expect(result[:data][:attributes][:npq_courses]).to eq []
      end
    end
  end
end
