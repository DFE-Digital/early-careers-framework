# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Core Induction Programme", type: :request do
  describe "GET /core-induction-programmes" do
    it "renders the core_induction_programmes page" do
      get "/core-induction-programmes"
      expect(response).to render_template(:index)
    end
  end

  describe "GET /core-induction-programmes/:id" do
    it "renders the core_induction_programme show page" do
      core_induction_programme = create(:core_induction_programme)
      get "/core-induction-programmes/#{core_induction_programme.id}"
      expect(response).to render_template(:show)
    end
  end

  describe "GET /download-export" do
    it "download export redirects to cip path when user is not admin" do
      get "/download-export"
      expect(response).to redirect_to(cip_index_path)
    end

    it "download export downloads a file when user is admin" do
      admin_user = create(:user, :admin)
      sign_in admin_user

      get "/download-export"
      expect(response.body).to include("CourseYear.import(")
      expect(response.body).to include("CourseModule.import(")
      expect(response.body).to include("CourseLesson.import(")
      expect(response.header["Content-Type"]).to eql "text/plain"
    end
  end
end
