# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Lead Provider confirmation of schools", type: :request do
  let(:schools) { create_list :school, rand(4..10) }
  let(:delivery_partner) { create :delivery_partner }
  let(:lead_provider) { create :user, :lead_provider }

  before do
    sign_in lead_provider

    set_session(:confirm_schools_form, {
      source: :csv,
      school_ids: schools.map(&:id),
      delivery_partner_id: delivery_partner.id,
    })
  end

  describe "GET /lead-providers/report-schools/confirm" do
    it "renders show template" do
      get "/lead-providers/report-schools/confirm"

      expect(response).to render_template "lead_providers/confirm_schools/show"
    end
  end

  describe "POST /lead-providers/report-schools/confirm/remove" do
    let(:school_to_remove) { schools.sample }

    it "removes given school from the list" do
      post "/lead-providers/report-schools/confirm/remove", params: { remove: { school_id: school_to_remove.id } }

      expect(session[:confirm_schools_form]["school_ids"]).not_to include school_to_remove.id
    end
  end
end
