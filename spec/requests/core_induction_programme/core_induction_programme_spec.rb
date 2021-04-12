# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Core Induction Programme", type: :request do
  let(:core_induction_programme) { create(:core_induction_programme) }

  describe "when an admin user is logged in" do
    before do
      admin_user = create(:user, :admin)
      sign_in admin_user
    end

    describe "GET /core-induction-programmes" do
      it "renders the core_induction_programmes page" do
        get "/core-induction-programmes"
        expect(response).to render_template(:index)
      end
    end

    describe "GET /core-induction-programmes/:id" do
      it "renders the core_induction_programmes page" do
        get "/core-induction-programmes/#{core_induction_programme.id}"
        expect(response).to render_template(:show)
      end
    end
  end

  describe "when an early career teacher is logged in" do
    before do
      early_career_teacher = create(:user, :early_career_teacher, { core_induction_programme: core_induction_programme })
      sign_in early_career_teacher
    end

    describe "GET /core-induction-programmes" do
      it "raises an error trying to access core_induction_programme index page" do
        expect { get "/core-induction-programmes" }.to raise_error Pundit::NotAuthorizedError
      end
    end

    describe "GET /core-induction-programmes/:id" do
      it "renders the core_induction_programme show page" do
        get "/core-induction-programmes/#{core_induction_programme.id}"
        expect(response).to render_template(:show)
      end

      it "raises an error when an ECT tries to access a cip they are not enrolled on" do
        second_core_induction_programme = create(:core_induction_programme)
        expect { get "/core-induction-programmes/#{second_core_induction_programme.id}" }.to raise_error Pundit::NotAuthorizedError
      end
    end
  end

  describe "being a visitor" do
    it "raises an error trying to access core_induction_programme index page" do
      expect { get "/core-induction-programmes" }.to raise_error Pundit::NotAuthorizedError
    end

    it "renders the core_induction_programme show page" do
      expect { get "/core-induction-programmes/#{core_induction_programme.id}" }.to raise_error Pundit::NotAuthorizedError
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
