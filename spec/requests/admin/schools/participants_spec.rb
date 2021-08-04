# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Schools::Participants", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:school) { create(:school) }
  let(:school_cohort) { create(:school_cohort, school: school) }

  let!(:ect_profile) { create :participant_profile, :ect, school_cohort: school_cohort }
  let!(:mentor_profile) { create :participant_profile, :mentor, school_cohort: school_cohort }
  let!(:npq_profile) { create(:participant_profile, :npq, school: school) }
  let!(:unrelated_profile) { create :participant_profile }
  let!(:withdrawn_profile) { create :participant_profile, :withdrawn, :mentor, school_cohort: school_cohort }

  before do
    sign_in admin_user
  end

  describe "GET /admin/schools/:school_slug/participants" do
    it "renders the index template" do
      get "/admin/schools/#{school.slug}/participants"

      expect(response).to render_template("admin/schools/participants/index")
    end

    it "only displays school's active participants" do
      get "/admin/schools/#{school.slug}/participants"

      expect(response.body).not_to include("No participants found for this school.")
      expect(assigns(:participant_profiles)).to include mentor_profile
      expect(assigns(:participant_profiles)).to include ect_profile
      expect(assigns(:participant_profiles)).not_to include npq_profile
      expect(assigns(:participant_profiles)).not_to include unrelated_profile
      expect(assigns(:participant_profiles)).not_to include withdrawn_profile
    end
  end
end
