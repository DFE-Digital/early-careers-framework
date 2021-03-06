# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Schools::Participants", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:school) { create(:school) }
  let!(:ect_user) do
    user = create(:user, :early_career_teacher)
    user.early_career_teacher_profile.update!(school: school)
    user
  end
  let!(:mentor_user) do
    user = create(:user, :mentor)
    user.mentor_profile.update!(school: school)
    user
  end
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
