# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Lead Provider school reporting: confirmation of schools", type: :request do
  let(:cohort) { create :cohort, :current }
  let(:schools) { create_list(:school, rand(4..10)).shuffle }
  let(:delivery_partner) { create :delivery_partner }
  let(:lead_provider_user) { create :user, :lead_provider }
  let(:lead_provider) { lead_provider_user.lead_provider }

  subject { response }

  before do
    sign_in lead_provider_user

    set_session(LeadProviders::ReportSchools::BaseController::SESSION_KEY, {
      source: :csv,
      school_ids: schools.map(&:id),
      delivery_partner_id: delivery_partner.id,
      cohort_id: cohort.id,
      lead_provider_id: lead_provider.id,
    })
  end

  describe "GET /lead-providers/report-schools/confirm" do
    before do
      get "/lead-providers/report-schools/confirm"
    end

    context "with some pre-selected schools" do
      it { is_expected.to render_template :show }

      it "preserves the order of schools" do
        expect(assigns(:schools).map(&:id)).to eq schools.map(&:id)
      end
    end

    context "when the list of pre-selected schools is empty" do
      let(:schools) { [] }

      it { is_expected.to render_template :no_schools }
    end
  end

  describe "POST /lead-providers/report-schools/confirm/remove_school" do
    let(:school_to_remove) { schools.sample }

    before do
      post "/lead-providers/report-schools/confirm/remove_school", params: { remove: { school_id: school_to_remove.id } }
    end

    it "removes given school from the list" do
      session_data = session[LeadProviders::ReportSchools::BaseController::SESSION_KEY]
      expect(session_data["school_ids"]).not_to include school_to_remove.id
    end

    it "displayes appropriate flash message" do
      expect(flash[:success]).to be_present
    end
  end
end
