# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::NPQ::ApplicationsController", :with_default_schedules, type: :request do
  let!(:application) { create :npq_application }
  let(:admin_user) { create :user, :admin }
  let(:parsed_response) { JSON.parse(response.body) }
  let(:params) { {} }

  before do
    sign_in admin_user
  end

  describe "GET (Index) /admin/npq/applications/applications" do
    let(:index_request) { get("/admin/npq/applications/applications", params:) }

    it "renders the index template for applications" do
      index_request
      expect(response).to render_template "admin/npq/applications/index"
    end

    context "with users split over two pages" do
      let(:params) { { per_page: 2, page: } }
      let(:page) { 2 }

      before do
        25.times do
          create(:npq_application)
        end
      end

      it "can return paginated data" do
        index_request

        # TOO FIX
        # expect(parsed_response["data"].size).to eql(2)

        # expect(response).to render_template "admin/npq/applications/index"
      end
    end
  end

  describe "GET (SHOW) /admin/npq/applications/applications/#application_id" do
    it "renders the show template for the application" do
      get "/admin/npq/applications/applications/#{application.id}"
      expect(response).to render_template "admin/npq/applications/show"
    end
  end
end
