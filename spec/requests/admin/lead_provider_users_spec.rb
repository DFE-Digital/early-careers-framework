# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::LeadProviderUsers", type: :request do
  let(:lead_provider_profile) { create(:lead_provider_profile) }
  let(:lead_provider) { lead_provider_profile.lead_provider }
  let(:lead_provider_user) { lead_provider_profile.user }

  before do
    admin_user = create(:user, :admin)
    sign_in admin_user
  end

  describe "GET /admin/lead_providers/:id/users/:id/edit" do
    it "renders the index template" do
      get "/admin/lead-providers/#{lead_provider.id}/users/#{lead_provider_user.id}/edit"

      expect(response.body).to include("Edit user details")
      expect(response).to render_template("admin/lead_provider_users/edit")
    end
  end

  describe "PATCH /admin/lead_providers/:id/users/:id" do
    let(:email) { "user@example.com" }

    it "updates the user and redirects to users page" do
      patch "/admin/lead-providers/#{lead_provider.id}/users/#{lead_provider_user.id}", params: {
        user: { email: email },
      }

      expect(lead_provider_user.reload.email).to eq email
      expect(response).to redirect_to(:admin_supplier_users)
      expect(flash[:notice]).to eq "Changes saved successfully"
    end

    context "when the user params are invalid" do
      it "renders error messages" do
        patch "/admin/lead-providers/#{lead_provider.id}/users/#{lead_provider_user.id}", params: {
          user: { email: nil },
        }

        expect(response.body).to include("Enter an email")
        expect(response).to render_template("admin/lead_provider_users/edit")
      end
    end
  end
end
