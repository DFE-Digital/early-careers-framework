# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Your schools", type: :request do
  let(:current_cohort) { create :cohort, :current }
  let(:other_cohort) { create :cohort, start_year: current_cohort.start_year - 1 }
  let(:lead_provider) { create :lead_provider, cohorts: [current_cohort, other_cohort] }
  let(:user) { create :user, :lead_provider, lead_provider: lead_provider }

  let!(:partnerships) { create_list :partnership, rand(2..4), lead_provider: lead_provider, cohort: current_cohort }
  let(:schools) { partnerships.map(&:school) }

  before do
    sign_in user
  end

  describe "GET /lead-providers/your_schools" do
    it "should show the Your schools page" do
      get lead_providers_your_schools_path

      expect(response).to render_template :index
    end

    it "should show the list of schools for the current cohort" do
      get lead_providers_your_schools_path

      expect(assigns(:selected_cohort)).to eq current_cohort
      expect(assigns(:total_provider_schools)).to eq partnerships.size
      expect(assigns(:partnerships)).to match_array partnerships
    end
  end
end
