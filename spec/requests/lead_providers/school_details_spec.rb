# frozen_string_literal: true

require "rails_helper"

RSpec.describe "School details spec", type: :request do
  let(:user) { create(:user, :lead_provider) }
  let!(:cohort) { create(:cohort, start_year: 2021) }

  before do
    sign_in user
  end

  describe "GET /lead-providers/school-details/:id" do
    let(:school) { create(:school) }

    context "when the user is the lead provider for the school" do
      before do
        create(:partnership, school: school, lead_provider: user.lead_provider, cohort: cohort)
      end

      it "should show the school detail page" do
        get lead_providers_school_detail_path(school)

        expect(response).to render_template :show
        expect(assigns(:school)).to eq school
      end
    end

    context "when school is not in a partnership with the lead provider" do
      it "should return not found" do
        expect {
          get lead_providers_school_detail_path(school)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
