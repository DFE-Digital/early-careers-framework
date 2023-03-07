# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::NPQ::ApplicationsController", :with_default_schedules, type: :request do
  before(:all) do
    21.times do
      create(:npq_application)
    end
  end

  let(:application) { NPQApplication.first }
  let(:admin_user) { create :user, :admin }

  before do
    sign_in admin_user
  end

  describe "GET (Index) /admin/npq/applications/applications" do
    it "renders the index template for applications" do
      get("/admin/npq/applications/applications")

      expect(response).to render_template "admin/npq/applications/index"
    end

    it "only returns first 20 results on page 1", :aggregate_failures do
      get("/admin/npq/applications/applications", params: { page: 1 })

      response_body = response.parsed_body

      expect(response_body.include?("NPQ Course 20")).to eq(true)
      expect(response_body.include?("NPQ Course 21")).to eq(false)
    end
  end

  describe "GET (SHOW) /admin/npq/applications/applications/#application_id" do
    it "renders the show template for the application" do
      get "/admin/npq/applications/applications/#{application.id}"

      expect(response).to render_template "admin/npq/applications/show"
    end
  end
end
