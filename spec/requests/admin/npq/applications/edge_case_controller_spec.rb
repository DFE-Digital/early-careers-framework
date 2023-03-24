# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::NPQ::Applications::EdgeCasesController", :with_default_schedules, type: :request do
  before do
    # Applications that wont show up
    create(:npq_application,
           works_in_school: true,
           works_in_childcare: false,
           funding_eligiblity_status_code: "no_institution")
    create(:npq_application,
           works_in_school: false,
           works_in_childcare: true,
           funding_eligiblity_status_code: "funded")

    # Applications that will show up
    create(:npq_application,
           works_in_school: false,
           works_in_childcare: false,
           employment_type: "local_authority_supply_teacher",
           employment_role: "Programme Leader",
           employer_name: "University of Newcastle upon Tyne",
           funding_eligiblity_status_code: "no_institution")
    create(:npq_application,
           works_in_school: false,
           works_in_childcare: false,
           employment_role: "Music Teacher",
           employer_name: "St Joseph's Specialist Trust",
           funding_eligiblity_status_code: "marked_ineligible_by_policy")
    create(:npq_application,
           works_in_school: false,
           works_in_childcare: false,
           employment_type: "hospital_school",
           employment_role: "Vice Principal",
           employer_name: "Salford council",
           funding_eligiblity_status_code: "awaiting_more_information")
    create(:npq_application,
           works_in_school: false,
           works_in_childcare: false,
           employment_type: "local_authority_supply_teacher",
           employment_role: "Art teacher",
           employer_name: "Bradford",
           funding_eligiblity_status_code: "re_register")
  end

  let(:application) { NPQApplication.first }
  let(:admin_user) { create :user, :admin }

  before do
    sign_in admin_user
  end

  describe "GET (Index) /admin/npq/applications/edge_cases" do
    it "renders the index template for edge case applications" do
      get("/admin/npq/applications/edge_cases")

      expect(response).to render_template "admin/npq/applications/edge_cases/index"
    end

    it "shows the correct edge case applications" do
      get("/admin/npq/applications/edge_cases")

      # only 4 users should appear as edge cases
      expect(response.parsed_body.scan(/John Doe/).length).to eq(4)
    end
  end

  describe "GET (SHOW) /admin/npq/applications/edge_cases/#application_id" do
    it "renders the show template for the application" do
      get "/admin/npq/applications/edge_cases/#{application.id}"

      expect(response).to render_template "admin/npq/applications/edge_cases/show"
    end
  end
end
