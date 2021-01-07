# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::LeadProviders", type: :request do
  let(:lead_provider) { FactoryBot.create(:lead_provider) }
  let(:lead_provider_name) { Faker::Company.name }

  describe "GET /admin/lead_providers" do
    it "renders the correct template" do
      # When
      get "/admin/lead_providers"

      # Then
      expect(response).to render_template(:index)
    end
  end

  describe "POST /admin/lead_providers" do
    it "redirects to the list of providers on success" do
      # When
      post "/admin/lead_providers", params: { lead_provider: {
        name: lead_provider_name,
      } }

      # Then
      expect(response).to redirect_to("/admin/lead_providers")
    end

    it "creates a new lead provider" do
      expect {
        post "/admin/lead_providers", params: { lead_provider: {
          name: lead_provider_name,
        } }
      }.to change { LeadProvider.count }.by(1)
    end

    it "creates a lead provider with the correct name" do
      # When
      post "/admin/lead_providers", params: { lead_provider: {
        name: lead_provider_name,
      } }

      # Then
      expect(LeadProvider.find_by_name(lead_provider_name)).not_to be_nil
    end

    it "does not create a lead provider when the name is empty" do
      expect {
        post "/admin/lead_providers", params: { lead_provider: {
          name: "",
        } }
      }.not_to(change { LeadProvider.count })
    end

    it "shows an error message when the name is empty" do
      # When
      post "/admin/lead_providers", params: { lead_provider: {
        name: "",
      } }

      # Then
      expect(response.body).to include("Enter a name")
    end
  end

  describe "GET /admin/lead_providers/new" do
    it "renders the correct template" do
      # When
      get "/admin/lead_providers/new"

      # Then
      expect(response).to render_template(:new)
    end
  end

  describe "GET /admin/lead_providers/:id/edit" do
    it "renders the correct template" do
      # When
      get "/admin/lead_providers/#{lead_provider.id}/edit"

      # Then
      expect(response).to render_template(:edit)
    end

    it "displays the current name of the lead provider" do
      # When
      get "/admin/lead_providers/#{lead_provider.id}/edit"

      # Then
      expect(response.body).to include(CGI.escapeHTML(lead_provider.name))
    end
  end

  describe "PUT /admin/lead_providers/:id" do
    it "redirects to the list of lead providers" do
      # When
      put "/admin/lead_providers/#{lead_provider.id}", params: { lead_provider: {
        name: lead_provider_name,
      } }

      # Then
      expect(response).to redirect_to("/admin/lead_providers")
    end
    it "updates the name of an existing lead provider" do
      # When
      put "/admin/lead_providers/#{lead_provider.id}", params: { lead_provider: {
        name: lead_provider_name,
      } }

      # Then
      expect(LeadProvider.find(lead_provider.id).name).to eq(lead_provider_name)
    end

    it "does not update the name of the lead provider when the new name is blank" do
      # Given
      previous_name = lead_provider.name

      # When
      put "/admin/lead_providers/#{lead_provider.id}", params: { lead_provider: {
        name: "",
      } }

      # Then
      expect(LeadProvider.find(lead_provider.id).name).to eq(previous_name)
    end

    it "displays an error message when the name is blank" do
      # When
      put "/admin/lead_providers/#{lead_provider.id}", params: { lead_provider: {
        name: "",
      } }

      # Then
      expect(response.body).to include("Enter a name")
    end
  end
end
