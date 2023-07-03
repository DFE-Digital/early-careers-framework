# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::NPQ::Applications::Analysis", type: :request do
  let!(:admin_user)                        { create :user, :admin }
  let(:cpd_lead_provider)                  { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:npq_lead_provider)                  { cpd_lead_provider.npq_lead_provider }
  let!(:accepted_application)              { create(:npq_application, :accepted, npq_lead_provider:) }
  let!(:accepted_application_with_payment) { create(:npq_application, :eligible_for_funding, :accepted, npq_lead_provider:) }
  let!(:rejected_application)              { create(:npq_application, npq_lead_provider:) }
  let!(:rejected_application_with_payment) { create(:npq_application, :accepted, :eligible_for_funding, npq_lead_provider:) }
  let!(:rejected_application_with_payable) { create(:npq_application, :accepted, :eligible_for_funding, npq_lead_provider:) }

  before do
    create(:npq_participant_declaration, :paid,    participant_profile: accepted_application_with_payment.profile, cpd_lead_provider:)
    create(:npq_participant_declaration, :paid,    participant_profile: rejected_application_with_payment.profile, cpd_lead_provider:)
    create(:npq_participant_declaration, :payable, participant_profile: rejected_application_with_payable.profile, cpd_lead_provider:)

    rejected_application.update_column(:lead_provider_approval_status, :rejected)
    rejected_application_with_payment.update_column(:lead_provider_approval_status, :rejected)
    rejected_application_with_payable.update_column(:lead_provider_approval_status, :rejected)

    sign_in admin_user
  end

  describe "GET /admin/npq/applications/analysis" do
    it "renders the index template for payments made against invalid NPQ applications" do
      get "/admin/npq/applications/analysis"
      expect(response).to render_template "admin/npq/applications/analysis/invalid_payments_analysis"
    end

    it "includes applications with invalid applications" do
      get "/admin/npq/applications/analysis"

      expect(assigns(:applications)).to include rejected_application_with_payment
      expect(assigns(:applications)).to include rejected_application_with_payable
    end

    it "does not include applications that are valid" do
      get "/admin/npq/applications/analysis"

      expect(assigns(:applications)).not_to include accepted_application_with_payment
    end

    it "does not include applications that have no associated payments" do
      get "/admin/npq/applications/analysis"

      expect(assigns(:applications)).not_to include accepted_application
      expect(assigns(:applications)).not_to include rejected_application
    end
  end
end
