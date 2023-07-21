# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::NPQ::Applications::EligibleForFundingController", type: :request do
  let(:npq_lead_provider) { create(:npq_lead_provider) }
  let(:application) do
    create(:npq_application,
           :funded,
           :accepted,
           :with_started_declaration,
           npq_lead_provider:,
           works_in_school: false,
           works_in_childcare: false,
           employment_type: "local_authority_supply_teacher",
           employment_role: "Programme Leader",
           employer_name: "University of Newcastle upon Tyne",
           funding_eligiblity_status_code: "no_institution")
  end

  let(:admin_user) { create :user, :admin }

  before do
    application
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
    let(:user) { create(:user, full_name: Faker::Name.name, email: Faker::Internet.email) }
    let(:admin_profile) { create(:admin_profile, user_id: user.id, super_user: true) }

    before do
      PaperTrail.request.whodunnit = User.find(user.id.to_s).id
      application.profile.participant_declarations.each { |d| d.update!(state: "submitted") }
    end

    it "renders the show template for the application", :aggregate_failures do
      patch("/admin/npq/applications/eligible_for_funding/#{application.id}", params:)

      expect(response).to redirect_to "/admin/npq/applications/edge_cases/#{application_id}"
      application.reload
      expect(application.funding_eligiblity_status_code).to eq("marked_ineligible_by_policy")
      expect(application.eligible_for_funding?).to eq(false)
    end

    context "when the npq_applciation fails to save" do
      before do
        allow_any_instance_of(NPQApplication).to receive(:save).with(context: :admin).and_return(false)
      end

      it "returns to the edit page", :aggregate_failures do
        patch("/admin/npq/applications/eligible_for_funding/#{application.id}", params:)
        expect(flash[:alert]).not_to be_empty
        expect(response).to redirect_to "/admin/npq/applications/edge_cases/#{application_id}"
        application.reload
        expect(application.funding_eligiblity_status_code).to eq("no_institution")
        expect(application.eligible_for_funding?).to eq(true)
      end
    end
  end
end
