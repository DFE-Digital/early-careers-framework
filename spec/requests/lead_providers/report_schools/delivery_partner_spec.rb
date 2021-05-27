# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Lead Provider school reporting: choosing delivery partner", type: :request do
  let(:user) { create(:user, :lead_provider) }
  let!(:cohort) { create(:cohort, :current) }

  before do
    sign_in user

    set_session(LeadProviders::ReportSchools::BaseController::SESSION_KEY, {
      cohort_id: cohort.id,
      lead_provider_id: user.lead_provider.id,
    })
  end

  describe "GET /lead-providers/report-schools/delivery-partner" do
    before do
      get "/lead-providers/report-schools/delivery-partner"
    end

    it { is_expected.to render_template :show }
  end

  describe "POST /lead-providers/report-schools/delivery-partner" do
    before do
      post(
        "/lead-providers/report-schools/delivery-partner",
        params: { lead_providers_report_schools_form: { delivery_partner_id: delivery_partner_id } },
      )
    end

    context "when a delivery partner has not been selected" do
      let(:delivery_partner_id) { "" }

      it "shows an error" do
        expect(response).to render_template :show
        expect(response.body).to include("Choose a delivery partner")
      end
    end

    context "when a delivery partner has been selected" do
      let(:lead_provider) { user.lead_provider }
      let(:delivery_partner) { create(:delivery_partner) }
      let(:delivery_partner_id) { delivery_partner.id }

      # TODO: We are missing this validation, the test should not pass without this block
      # before do
      #   ProviderRelationship.create(lead_provider: lead_provider, delivery_partner: delivery_partner, cohort: Cohort.current)
      # end

      it "redirects to the csv upload page" do
        expect(response).to redirect_to lead_providers_report_schools_csv_path
      end

      it "updates delivery partner id in session form" do
        session_data = session[LeadProviders::ReportSchools::BaseController::SESSION_KEY]
        expect(session_data["delivery_partner_id"]).to eq delivery_partner_id
      end
    end
  end
end
