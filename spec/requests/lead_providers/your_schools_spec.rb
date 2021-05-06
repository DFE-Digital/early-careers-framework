# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Your schools", type: :request do
  let(:cohort) { create(:cohort, start_year: Time.zone.now.year) }
  let(:lead_provider) { create(:lead_provider, cohorts: [cohort]) }
  let(:user) { create(:user) }
  let(:schools) { create_list(:school, 2) }
  let(:not_this_cohort_school) { create(:school) }

  before do
    create(:lead_provider_profile, user: user, lead_provider: lead_provider)
    schools.each do |school|
      create(:partnership, school: school, lead_provider: lead_provider, cohort: cohort)
    end
    create(:partnership, school: not_this_cohort_school, lead_provider: lead_provider,
                         cohort: create(:cohort, start_year: Time.zone.now.year + 1))
    sign_in user
  end

  describe "GET /lead-providers/your_schools" do
    it "should show the Your schools page" do
      get lead_providers_your_schools_path

      expect(response).to render_template :index
    end

    it "should show the list of schools for the current cohort" do
      get lead_providers_your_schools_path
      expect(assigns(:selected_cohort)).to eq cohort
      expect(assigns(:schools)).to match_array schools
      expect(assigns(:schools)).not_to include not_this_cohort_school
    end
  end
end
