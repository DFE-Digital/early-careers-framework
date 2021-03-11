# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Core Induction Programme Module", type: :request do
  let(:course_module) { FactoryBot.create(:course_module) }
  let(:course_module_url) { "/years/#{course_module.course_year.id}/modules/#{course_module.id}" }

  describe "when an admin user is logged in" do
    before do
      admin_user = create(:user, :admin)
      sign_in admin_user
    end

    describe "GET /years/:years_id/modules/module_id" do
      it "renders the cip module page" do
        get course_module_url
        expect(response).to render_template(:show)
      end
    end

    describe "GET /years/:years_id/modules/module_id/edit" do
      it "renders the cip module edit page" do
        get "#{course_module_url}/edit"
        expect(response).to render_template(:edit)
      end
    end

    describe "PUT /years/:years_id/modules/module_id" do
      it "renders a preview of changes to module" do
        put course_module_url, params: { commit: "See preview", course_module: { content: "Extra content" } }
        expect(response).to render_template(:edit)
        expect(response.body).to include("Extra content")
        course_module.reload
        expect(course_module.content).not_to include("Extra content")
      end

      it "redirects to the module page when saving content" do
        put course_module_url, params: { commit: "Save changes", course_module: { content: "Adding new content" } }
        expect(response).to redirect_to(course_module_url)
        get course_module_url
        expect(response.body).to include("Adding new content")
      end

      it "redirects to the module page when saving title" do
        put course_module_url, params: { commit: "Save changes", course_module: { title: "New title" } }
        expect(response).to redirect_to(course_module_url)
        get course_module_url
        expect(response.body).to include("New title")
      end
    end
  end

  describe "when a non-admin user is logged in" do
    before do
      user = create(:user)
      sign_in user
    end

    describe "GET /years/:years_id/modules/module_id" do
      it "renders the cip module page" do
        get course_module_url
        expect(response).to render_template(:show)
      end
    end

    describe "GET /years/:years_id/modules/module_id/edit" do
      it "redirects to the sign in page" do
        expect { get "#{course_module_url}/edit" }.to raise_error Pundit::NotAuthorizedError
      end
    end
  end

  describe "when a non-user is accessing the module page" do
    describe "GET /years/:years_id/modules/module_id/" do
      it "renders the cip module page" do
        get course_module_url
        expect(response).to render_template(:show)
      end
    end

    describe "GET /years/:years_id/modules/module_id/edit" do
      it "redirects to the sign in page" do
        get "#{course_module_url}/edit"
        expect(response).to redirect_to("/users/sign_in")
      end
    end

    describe "PUT /years/:years_id/modules/module_id" do
      it "redirects to the sign in page" do
        put course_module_url, params: { commit: "Save changes", course_module: { content: course_module.content } }
        expect(response).to redirect_to("/users/sign_in")
      end
    end
  end
end
