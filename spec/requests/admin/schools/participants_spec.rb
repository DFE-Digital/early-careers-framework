# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Schools::Participants", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:school) { create(:school) }
  let!(:ect_profile) { create :participant_profile, :ect, school: school }
  let!(:mentor_profile) { create :participant_profile, :mentor, school: school }

  let!(:unrelated_profile) { create :participant_profile }

  before do
    sign_in admin_user
  end

  describe "GET /admin/schools/:school_id/participants" do
    it "renders the index template" do
      get "/admin/schools/#{school.id}/participants"

      expect(response).to render_template("admin/schools/participants/index")
    end

    it "only displays school's participants" do
      get "/admin/schools/#{school.id}/participants"

      expect(response.body).not_to include("No participants found for this school.")
      expect(assigns(:participant_profiles)).to include(mentor_profile)
      expect(assigns(:participant_profiles)).to include(ect_profile)
      expect(assigns(:participant_profiles)).not_to include(unrelated_profile)
    end
  end
end
