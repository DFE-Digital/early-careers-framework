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

    describe "GET /years/new" do
      it "renders the cip new years page" do
        get "/years/new"
        expect(response).to render_template(:new)
      end
    end

    describe "POST /years" do
      it "creates a new year, redirecting to the CIP homepage" do
        expect(create_course_year).to redirect_to("/core-induction-programmes")
      end
    end

    describe "GET /years/years_id/edit" do
      it "render the cip years edit page" do
        get "#{course_year_url}/edit", params: { course_year: { id: course_year.id } }
        expect(response).to render_template(:edit)
      end
    end

    describe "PUT /years/years_id" do
      it "renders a preview of changes to a year" do
        put course_year_url, params: { commit: "See preview", course_year: { content: "Extra content" } }
        expect(response).to render_template(:edit)
        expect(response.body).to include("Extra content")
        course_year.reload
        expect(course_year.content).not_to include("Extra content")
      end

      it "redirects to the year page and updates content when saving changes" do
        create_cip
        put course_year_url, params: { commit: "Save changes", course_year: { content: "Adding new content" } }
        expect(response).to redirect_to(cip_url(course_year.core_induction_programme))
        get cip_url(course_year.core_induction_programme)
        expect(response.body).to include("Adding new content")
      end

      it "redirects to the year page when saving title" do
        create_cip
        put course_year_url, params: { commit: "Save changes", course_year: { title: "New title" } }
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

    describe "GET /years/new" do
      it "raises an error when trying to create a new year page" do
        expect { get "/years/new" }.to raise_error Pundit::NotAuthorizedError
      end
    end

    describe "POST /years" do
      it "raises an error when trying to post a new year" do
        expect { create_course_year }.to raise_error Pundit::NotAuthorizedError
      end
    end

    describe "GET /years/years_id/edit" do
      it "raises an error when trying to access edit page" do
        expect { get "#{course_year_url}/edit" }.to raise_error Pundit::NotAuthorizedError
      end
    end
  end

  describe "when a non-user is accessing the year page" do
    describe "GET /years/new" do
      it "raises an error when trying to create a new year page" do
        get "/years/new"
        expect(response).to redirect_to("/users/sign_in")
      end
    end

    describe "POST /years" do
      it "raises an error when trying to post a new year" do
        expect(create_course_year).to redirect_to("/users/sign_in")
      end
    end

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

private

def create_course_year
  post "/years", params: { course_year: {
    title: "Additional year title",
    content: "Additional year content",
  } }
end

def create_cip
  FactoryBot.create(:core_induction_programme, course_year_one: course_year)
end
