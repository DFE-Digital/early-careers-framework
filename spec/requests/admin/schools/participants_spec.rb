# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Schools::Participants", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:school) { create(:school) }
  let(:school_cohort) { create(:school_cohort, school: school) }
  let!(:ect_user) { create(:user, :early_career_teacher, school_cohort: school_cohort) }
  let!(:mentor_user) { create(:user, :mentor, school_cohort: school_cohort) }
  let!(:unrelated_user) { create(:user, :mentor) }

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
      expect(assigns(:participants)).to include(mentor_user)
      expect(assigns(:participants)).not_to include(unrelated_user)
    end
  end
end
