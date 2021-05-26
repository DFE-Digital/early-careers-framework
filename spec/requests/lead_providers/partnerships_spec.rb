# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Lead provider partnerships spec", type: :request do
  let(:user) { create :user, :lead_provider }
  let!(:cohort) { create :cohort }

  before do
    sign_in user
  end

  describe "GET /lead-providers/partnerships/:id" do
    let(:partnership) { create :partnership, cohort: cohort }

    context "when the user is the lead provider for the school" do
      it "should show the partnership page" do
        get lead_providers_partnership_path(partnership)

        expect(response).to render_template :show
        expect(assigns(:partnership)).to eq partnership
      end
    end
  end
end
