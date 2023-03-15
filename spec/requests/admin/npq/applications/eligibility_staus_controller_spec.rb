# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::NPQ::Applications::EligibilityStatusController", :with_default_schedules, type: :request do
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

  describe "GET (EDIT) /admin/npq/applications/eligibility_status/:id/edit" do
    it "renders the index template for edge case applications" do
      get("/admin/npq/applications/eligibility_status/#{application.id}/edit")

      expect(response).to render_template "admin/npq/applications/eligibility_status/edit"
    end

    it "shows the correct edge case applications" do
      get("/admin/npq/applications/eligibility_status/#{application.id}/edit")

      expect(response.body.include?("What is their funding eligibility status code?")).to eq(true)
    end
  end

  describe "PATCH (UPDATE) /admin/npq/applications/eligibility_status/:id" do
    let(:params) { { npq_application: { "funding_eligiblity_status_code"=>"re_register" } } }
    let(:application_id) { application.id }

    it "renders the show template for the application", :aggregate_failures do
      patch("/admin/npq/applications/eligibility_status/#{application.id}", params:)

      expect(response).to redirect_to "/admin/npq/applications/edge_cases/#{application_id}"
      application.reload
      expect(application.funding_eligiblity_status_code).to eq("re_register")
      expect(application.eligible_for_funding?).to eq(false)
    end
  end
end
