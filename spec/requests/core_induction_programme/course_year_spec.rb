# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Core Induction Programme Year", type: :request do
  let(:course_year) { FactoryBot.create(:course_year) }
  let(:course_year_url) { "/years/#{course_year.id}" }

  describe "when an admin user is logged in" do
    before do
      admin_user = create(:user, :admin)
      sign_in admin_user
    end

    describe "GET /years/years_id/edit" do
      it "render the cip years edit page" do
        get "#{course_year_url}/edit"
        expect(response).to render_template(:edit)
      end
    end

    describe "PUT /years/years_id" do
      it "renders a preview of changes to a year" do
        put course_year_url, params: { commit: "See preview", content: "Extra content" }
        expect(response).to render_template(:edit)
        expect(response.body).to include("Extra content")
        course_year.reload
        expect(course_year.content).not_to include("Extra content")
      end

      it "redirects to the year page and updates content when saving changes" do
        put course_year_url, params: { commit: "Save changes", content: "Adding new content" }
        expect(response).to redirect_to(cip_url(course_year.core_induction_programme))
        get cip_url(course_year.core_induction_programme)
        expect(response.body).to include("Adding new content")
      end

      it "redirects to the year page when saving title" do
        put course_year_url, params: { commit: "Save changes", title: "New title" }
        expect(response).to redirect_to(cip_url(course_year.core_induction_programme))
        get cip_url(course_year.core_induction_programme)
        expect(response.body).to include("New title")
      end
    end
  end

  describe "when a non-admin user is logged in" do
    before do
      user = create(:user)
      sign_in user
    end

    describe "GET /years/years_id/edit" do
      it "raises an error when trying to access edit page" do
        expect { get "#{course_year_url}/edit" }.to raise_error Pundit::NotAuthorizedError
      end
    end
  end

  describe "when a non-user is accessing the year page" do
    describe "GET /years/years_id/edit" do
      it "redirects to the sign in page" do
        get "#{course_year_url}/edit"
        expect(response).to redirect_to("/users/sign_in")
      end
    end

    describe "PUT /years/years_id" do
      it "redirects to the sign in page" do
        put course_year_url, params: { commit: "Save changes", content: course_year.content }
        expect(response).to redirect_to("/users/sign_in")
      end
    end
  end
end
