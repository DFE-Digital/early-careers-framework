# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::NPQ::Applications::EligibleForFundingController", :with_default_schedules, type: :request do
  let(:application) do
    create(:npq_application,
           works_in_school: false,
           works_in_childcare: false,
           employment_type: "local_authority_supply_teacher",
           employment_role: "Programme Leader",
           employer_name: "University of Newcastle upon Tyne",
           funding_eligiblity_status_code: "no_institution")
  end
  let(:admin_user) { create :user, :admin }

  before do
    sign_in admin_user
  end

  describe "GET (EDIT) /admin/npq/applications/eligible_for_funding/:id/edit" do
    it "renders the index template for edge case applications" do
      get("/admin/npq/applications/eligible_for_funding/#{application.id}/edit")

      expect(response).to render_template "admin/npq/applications/eligible_for_funding/edit"
    end

    it "shows the correct edge case applications" do
      get("/admin/npq/applications/eligible_for_funding/#{application.id}/edit")

      expect(response.body.include?("Is eligible for funding?")).to eq(true)
    end
  end

  describe "PATCH (UPDATE) /admin/npq/applications/eligible_for_funding/:id" do
    let(:params) { { npq_application: { "eligible_for_funding"=>"false" } } }
    let(:application_id) { application.id }

    it "renders the show template for the application", :aggregate_failures do
      patch("/admin/npq/applications/eligible_for_funding/#{application.id}", params:)

      expect(response).to redirect_to "/admin/npq/applications/edge_cases/#{application_id}"
      application.reload
      expect(application.funding_eligiblity_status_code).to eq("marked_ineligible_by_policy")
      expect(application.eligible_for_funding?).to eq(false)
    end
  end
end
