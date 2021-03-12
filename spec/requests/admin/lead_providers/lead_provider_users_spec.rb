# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::LeadProviders::LeadProviderUsers", type: :request do
  let(:lead_provider_profile) { create(:lead_provider_profile) }
  let(:lead_provider_user) { lead_provider_profile.user }
  let(:lead_provider_user_two) { create(:user, :lead_provider, full_name: "Emma Dow", email: "emma-dow@example.com") }
  let(:lead_provider_profile_two) { lead_provider_user_two.lead_provider_profile }

  before do
    admin_user = create(:user, :admin)
    sign_in admin_user
    lead_provider_user
    lead_provider_user_two
  end

  describe "GET /admin/suppliers/lead_providers/users/:id/edit" do
    it "renders the index template" do
      get "/admin/suppliers/lead-providers/users/#{lead_provider_user.id}/edit"

      expect(response.body).to include("Edit user details")
      expect(response).to render_template("admin/suppliers/lead_provider_users/edit")
    end
  end

  describe "PATCH /admin/suppliers/lead_providers/users/:id" do
    let(:email) { "user@example.com" }

    it "updates the user and redirects to users page" do
      patch "/admin/suppliers/lead-providers/users/#{lead_provider_user.id}", params: {
        user: { email: email },
      }

      expect(lead_provider_user.reload.email).to eq email
      expect(response).to redirect_to(:admin_supplier_users)
      expect(flash[:notice]).to eq "Changes saved successfully"
    end

    context "when the user params are invalid" do
      it "renders error messages" do
        patch "/admin/suppliers/lead-providers/users/#{lead_provider_user.id}", params: {
          user: { email: nil },
        }

        expect(response.body).to include("Enter an email")
        expect(response).to render_template("admin/suppliers/lead_provider_users/edit")
      end
    end
  end

  describe "DELETE /admin/suppliers/lead_providers/users/:id/" do
    it "marks the lead_provider profile as deleted" do
      delete "/admin/suppliers/lead-providers/users/#{lead_provider_user_two.id}"

      lead_provider_profile_two.reload
      lead_provider_user_two.reload
      expect(lead_provider_profile_two.discarded?).to be true
      expect(lead_provider_user_two.discarded?).to be true
    end

    it "redirects to the lead_provider users index page" do
      delete "/admin/suppliers/lead-providers/users/#{lead_provider_user_two.id}"

      expect(response).to redirect_to("/admin/suppliers/users?user_deleted=true")
      expect(response.body).not_to include(CGI.escapeHTML(lead_provider_profile_two.user.full_name))
    end
  end
end
