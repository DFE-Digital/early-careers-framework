# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Participants", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:cohort) { create(:cohort) }
  let(:school) { create(:school) }
  let!(:mentor_user) do
    user = create(:user, :mentor)
    user.mentor_profile.update!(school: school)
    user
  end
  let!(:ect_user) do
    user = create(:user, :early_career_teacher)
    user.early_career_teacher_profile.update!(school: school, cohort: cohort, mentor_profile: mentor_user.mentor_profile)
    user
  end

  before do
    sign_in admin_user
  end

  describe "GET /admin/participants/:id" do
    it "renders the show template" do
      get "/admin/participants/#{mentor_user.id}"
      expect(response).to render_template("admin/participants/show")
    end

    it "shows the correct participant" do
      get "/admin/participants/#{ect_user.id}"
      expect(response.body).to include(ect_user.full_name)
      expect(response.body).to include(mentor_user.full_name)
    end
  end
end
