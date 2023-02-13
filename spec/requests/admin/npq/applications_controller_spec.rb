# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::NPQ::ApplicationsController", :with_default_schedules, type: :request do
  let!(:admin_user) { create :user, :admin }
  let!(:application) { create :npq_application }

  before do
    sign_in admin_user
  end

  describe "GET /admin/npq/applications/applications" do
    it "renders the index template for applications" do
      get "/admin/npq/applications/applications"
      expect(response).to render_template "admin/npq/applications/index"
    end
  end

  describe "GET /admin/npq/applications/applications/#application_id" do
    it "renders the show template for the application" do
      get "/admin/npq/applications/applications/#{application.id}"
      expect(response).to render_template "admin/npq/applications/show"
    end
  end
end
