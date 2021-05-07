# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Report schools spec", type: :request do
  let(:user) { create(:user, :lead_provider) }
  let!(:cohort) { create(:cohort, :current) }

  before do
    sign_in user
  end

  describe "GET /lead-providers/report-schools/start" do
    it "should show the start page to a lead provider" do
      get start_lead_providers_report_schools_path

      expect(response).to render_template :start
    end
  end

  describe "POST /lead-providers/report-schools/check-delivery-partner" do
    it "shows an error if nothing is selected" do
      post "/lead-providers/report-schools/check-delivery-partner", params: { lead_provider_delivery_partner_form: { delivery_partner_id: "" } }

      expect(response).to render_template :choose_delivery_partner
      expect(response.body).to include("Choose a delivery partner")
    end

    context "when a delivery partner has been selected" do
      let(:lead_provider) { user.lead_provider }
      let(:delivery_partner) { create(:delivery_partner) }

      before do
        ProviderRelationship.create(lead_provider: lead_provider, delivery_partner: delivery_partner, cohort: Cohort.current)
      end

      it "redirects to the csv upload page" do
        post "/lead-providers/report-schools/check-delivery-partner", params: {
          lead_provider_delivery_partner_form: { delivery_partner_id: delivery_partner.id },
        }

        expect(response).to redirect_to new_lead_providers_report_schools_partnership_csv_uploads_path
      end
    end
  end

  describe "GET /lead-providers/report-schools/success" do
    let(:schools) { create_list :school, rand(3..5) }
    let(:delivery_partner) { create :delivery_partner }

    before do
      set_session(:confirm_schools_form, { school_ids: schools.map(&:id), delivery_partner_id: delivery_partner.id })
    end

    it "displays success message" do
      get success_lead_providers_report_schools_path

      expect(response).to render_template :success
    end

    it "removes confirmation form from session" do
      get success_lead_providers_report_schools_path

      expect(session).not_to have_key(:confirm_schools_form)
    end
  end
end
