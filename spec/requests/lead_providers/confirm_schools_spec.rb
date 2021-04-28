# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Lead Provider confirmation of schools", type: :request do
  let(:schools) { create_list :school, rand(4..10) }
  let(:delivery_partner) { create :delivery_partner }
  let(:lead_provider) { create :user, :lead_provider }

  subject { response }

  before do
    sign_in lead_provider

    set_session(:confirm_schools_form, {
      source: :csv,
      school_ids: schools.map(&:id),
      delivery_partner_id: delivery_partner.id,
    })
  end

  describe "GET /lead-providers/report-schools/confirm" do
    before do
      get "/lead-providers/report-schools/confirm"
    end

    context "with some pre-selected schools" do
      it { is_expected.to render_template "lead_providers/confirm_schools/show" }
    end

    context "when the list of pre-selected schools is empty" do
      let(:schools) { [] }

      it { is_expected.to render_template "lead_providers/confirm_schools/no_schools" }
    end
  end

  describe "POST /lead-providers/report-schools/confirm/remove" do
    let(:school_to_remove) { schools.sample }

    before do
      post "/lead-providers/report-schools/confirm/remove", params: { remove: { school_id: school_to_remove.id } }
    end

    it "removes given school from the list" do
      expect(session[:confirm_schools_form]["school_ids"]).not_to include school_to_remove.id
    end

    it "displayes appropriate flash message" do
      expect(flash[:success]).to be_present
    end
  end
end
