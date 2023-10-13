# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::NPQ::ParticipantOutcomesController do
  let(:user) { create(:user, :finance) }
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }
  let(:npq_application) { create(:npq_application, :accepted, npq_lead_provider:) }
  let(:participant_profile) { npq_application.profile }
  let(:participant_declaration) { create(:npq_participant_declaration, participant_profile:, cpd_lead_provider:) }
  let!(:participant_outcome) { create(:participant_outcome, participant_declaration:) }

  before do
    sign_in user
  end

  describe "GET #resend" do
    it "redirects correctly to finance participant drilldown page" do
      get "/finance/npq/participant_outcomes/#{participant_outcome.id}/resend"

      expect(response).to redirect_to("/finance/participants/#{participant_profile.id}")
    end

    it "calls the correct method" do
      expect_any_instance_of(ParticipantOutcome::NPQ).to receive(:resend!).and_call_original

      get "/finance/npq/participant_outcomes/#{participant_outcome.id}/resend"
    end
  end
end
