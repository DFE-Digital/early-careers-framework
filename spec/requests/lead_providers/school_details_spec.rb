# frozen_string_literal: true

require "rails_helper"

RSpec.describe "School details spec", type: :request do
  let(:user) { create(:user, :lead_provider) }
  let!(:cohort) { create(:cohort, :current) }

  before do
    sign_in user
  end

  describe "GET /lead-providers/school-details/:id" do
    let(:school) { create(:school) }

    it "should show the school detail page" do
      get lead_providers_school_detail_path(school)

      expect(response).to render_template :show
      expect(assigns(:school)).to eq school
    end
  end
end
