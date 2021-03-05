# frozen_string_literal: true

require "rails_helper"
include NewSupplierHelper

RSpec.describe "Admin::Suppliers::DeliveryPartners", type: :request do
  let(:delivery_partner_name) { Faker::Company.name }
  let(:cohort) { create(:cohort) }
  let(:lead_provider) { create(:lead_provider, cohorts: [cohort]) }
  let(:delivery_partner) { create(:delivery_partner) }

  before do
    admin_user = create(:user, :admin)
    sign_in admin_user
  end

  describe "GET /admin/suppliers/new/delivery-partner/choose-lps" do
    it "renders the choose_lead_providers template" do
      # When
      get "/admin/suppliers/new/delivery-partner/choose-lps"

      # Then
      expect(response).to render_template(:choose_lead_providers)
    end
  end

  describe "POST /admin/suppliers/new/delivery-partner/choose-lps" do
    before do
      given_I_have_chosen_supplier_name(delivery_partner_name)
      given_I_have_chosen_delivery_partner_type
    end

    it "redirects to the review page" do
      when_I_choose_lps_and_cohorts([lead_provider], { lead_provider => [cohort] })

      # Then
      expect(response).to redirect_to("/admin/suppliers/new/delivery-partner/review")
    end

    it "sets the correct lead provider and cohort" do
      when_I_choose_lps_and_cohorts([lead_provider], { lead_provider => [cohort] })

      # Then
      given_I_have_confirmed_my_choices

      new_delivery_partner = DeliveryPartner.order(:created_at).last
      expect(new_delivery_partner.lead_providers).to contain_exactly(lead_provider)
      expect(new_delivery_partner.provider_relationships.map(&:cohort)).to contain_exactly(cohort)
    end

    it "creates a provider relationship for each cohort" do
      # Given
      cohort2 = create(:cohort)
      selected_lead_provider = lead_provider
      selected_lead_provider.cohorts << cohort2

      when_I_choose_lps_and_cohorts([lead_provider], { lead_provider => [cohort, cohort2] })

      # Then
      given_I_have_confirmed_my_choices

      new_delivery_partner = DeliveryPartner.order(:created_at).last
      expect(new_delivery_partner.provider_relationships.count).to eq(2)
      expect(new_delivery_partner.provider_relationships.where(lead_provider: lead_provider, cohort: cohort).count).to eq(1)
      expect(new_delivery_partner.provider_relationships.where(lead_provider: lead_provider, cohort: cohort2).count).to eq(1)
    end

    it "displays an error when no lead provider is selected" do
      when_I_choose_lps_and_cohorts([], {})

      # Then
      expect(response).to render_template(:choose_lead_providers)
      expect(response.body).to include("Choose at least one")
    end

    it "displays an error when no cohorts are selected for a lead provider" do
      second_lead_provider = create(:lead_provider)
      when_I_choose_lps_and_cohorts([lead_provider, second_lead_provider], { lead_provider => [cohort] })

      # Then
      expect(response).to render_template(:choose_lead_providers)
      expect(response.body).to include("Choose at least one cohort for every selected lead provider")
    end
  end

  describe "POST /admin/suppliers/new/delivery-partner" do
    before do
      given_I_have_chosen_supplier_name(delivery_partner_name)
      given_I_have_chosen_delivery_partner_type
      given_I_have_chosen_lps_and_cohorts([lead_provider], { lead_provider => [cohort] })
    end

    it "redirects to the list of providers on success" do
      when_I_confirm_my_choices

      # Then
      new_delivery_partner = DeliveryPartner.order(:created_at).last
      expect(response).to redirect_to("/admin/suppliers/new/delivery-partner/success?delivery_partner=#{new_delivery_partner.id}")
    end

    it "creates a new delivery partner" do
      expect {
        when_I_confirm_my_choices
      }.to change { DeliveryPartner.count }.by(1)
    end

    it "creates a delivery partner with the correct name" do
      # When
      post "/admin/suppliers/new/delivery-partner", params: {}

      # Then
      expect(DeliveryPartner.find_by_name(delivery_partner_name)).not_to be_nil
    end
  end

  describe "GET /admin/suppliers/delivery-partners/{delivery_partner.id}" do
    it "renders the show template" do
      get "/admin/suppliers/delivery-partners/#{delivery_partner.id}"
      expect(response).to render_template("admin/suppliers/delivery_partners/show")
      expect(response.body).to include(CGI.escapeHTML(delivery_partner.name))
    end
  end

  describe "GET /admin/suppliers/delivery-partners/{delivery_partner.id}/delete" do
    it "render the delete template" do
      get "/admin/suppliers/delivery-partners/#{delivery_partner.id}/delete"
      expect(response).to render_template("admin/suppliers/delivery_partners/delete")
      expect(response.body).to include(CGI.escapeHTML(delivery_partner.name))
    end
  end
end
