# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::LeadProviders::LeadProviderUsers", type: :request do
  let(:lead_provider_profile) { create(:lead_provider_profile) }
  let(:lead_provider_user) { lead_provider_profile.user }
  let(:lead_provider_user_two) { create(:user, :lead_provider, full_name: "Emma Dow", email: "emma-dow@example.com") }
  let(:lead_provider_profile_two) { lead_provider_user_two.lead_provider_profile }
  let(:admin_user) { create(:user, :admin) }

  before do
    sign_in admin_user
    lead_provider_user
    lead_provider_user_two
  end

  describe "GET /admin/suppliers/lead_providers/:lead_provider_id/users/:id/edit" do
    it "renders the index template" do
      get "/admin/suppliers/lead-providers/#{lead_provider_user.lead_provider.id}/users/#{lead_provider_user.id}/edit"

      expect(response.body).to include("Edit user details")
      expect(response).to render_template("admin/suppliers/lead_provider_users/edit")
    end
  end

  describe "PATCH /admin/suppliers/lead_providers/:lead_provider_id/users/:id" do
    let(:email) { "user@example.com" }

    it "updates the user and redirects to users page" do
      patch "/admin/suppliers/lead-providers/#{lead_provider_user.lead_provider.id}/users/#{lead_provider_user.id}", params: {
        user: { email: },
      }

      expect(lead_provider_user.reload.email).to eq email
      expect(response).to redirect_to(:admin_supplier_users)
      expect(flash[:success][:content]).to eq "Changes saved successfully"
    end

    context "when the user params are invalid" do
      it "renders error messages" do
        patch "/admin/suppliers/lead-providers/#{lead_provider_user.lead_provider.id}/users/#{lead_provider_user.id}", params: {
          user: { email: nil },
        }

        expect(response.body).to include("Enter an email")
        expect(response).to render_template("admin/suppliers/lead_provider_users/edit")
      end
    end

    context "when an audited action", versioning: true do
      let(:current_admin) { admin_user }

      before do
        patch "/admin/suppliers/lead-providers/#{lead_provider_user.lead_provider.id}/users/#{lead_provider_user.id}", params: {
          user: { email: },
        }
      end

      include_examples "audits changes"
    end
  end

  describe "DELETE /admin/suppliers/lead_providers/:lead_provider_id/users/:id/", versioning: true do
    before do
      delete "/admin/suppliers/lead-providers/#{lead_provider_user.lead_provider.id}/users/#{lead_provider_user_two.id}"
    end

    it "deletes the lead_provider" do
      expect(LeadProviderProfile.find_by_id(lead_provider_profile_two.id)).to be_nil
      expect(User.find_by_id(lead_provider_user_two.id)).to be_nil
    end

    it "creates a paper trail" do
      expect(PaperTrail::Version.where(item_id: lead_provider_user_two.id, event: "destroy")).to exist
      expect(PaperTrail::Version.where(item_id: lead_provider_profile_two.id, event: "destroy")).to exist
    end

    it "redirects to the lead_provider users index page" do
      expect(response).to redirect_to("/admin/suppliers/users")
      expect(response.body).not_to include(CGI.escapeHTML(lead_provider_profile_two.user.full_name))
    end
  end
end
