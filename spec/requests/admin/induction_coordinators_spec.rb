# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::InductionCoodinators", type: :request do
  let(:induction_coordinator_profile) { create(:induction_coordinator_profile) }
  let(:induction_coordinator) { induction_coordinator_profile.user }

  before do
    admin_user = create(:user, :admin)
    sign_in admin_user
  end

  describe "GET /admin/induction_coordinators/:id/edit" do
    it "renders the index template" do
      get "/admin/induction-coordinators/#{induction_coordinator.id}/edit"

      expect(response.body).to include("Edit user details")
      expect(response).to render_template("admin/induction_coordinators/edit")
    end
  end

  describe "PATCH /admin/induction-coordinatorsrs/:id" do
    let(:email) { "user@example.com" }

    it "updates the user and redirects to users page" do
      patch "/admin/induction-coordinators/#{induction_coordinator.id}", params: {
        user: { email: email },
      }

      expect(induction_coordinator.reload.email).to eq email
      expect(response).to redirect_to(:admin_supplier_users)
      expect(flash[:notice]).to eq "Changes saved successfully"
    end

    context "when the user params are invalid" do
      it "renders error messages" do
        patch "/admin/induction-coordinators/#{induction_coordinator.id}", params: {
          user: { email: nil },
        }

        expect(response.body).to include("Enter an email")
        expect(response).to render_template("admin/induction_coordinators/edit")
      end
    end
  end
end
