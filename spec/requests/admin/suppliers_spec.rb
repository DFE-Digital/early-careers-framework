# frozen_string_literal: true

require "rails_helper"
include NewSupplierHelper

RSpec.describe "Admin::Suppliers", type: :request do
  let(:supplier_name) { Faker::Company.name }
  let(:cohort) { create(:cohort) }
  let(:lead_provider) { create(:lead_provider, cohorts: [cohort]) }
  before do
    admin_user = create(:user, :admin)
    sign_in admin_user
  end

  describe "GET /admin/suppliers/new" do
    it "renders the new template" do
      get "/admin/suppliers/new"

      expect(response).to render_template(:new)
    end
  end

  describe "POST /admin/suppliers/new" do
    it "redirects to the supplier type page" do
      when_I_choose_a_supplier_name(supplier_name)

      expect(response).to redirect_to("/admin/suppliers/new/supplier-type")
    end

    it "Sets the correct name" do
      when_I_choose_a_supplier_name(supplier_name)

      # Then
      given_I_have_chosen_delivery_partner_type
      given_I_have_chosen_lps_and_cohorts([lead_provider], { lead_provider => [cohort] })
      given_I_have_confirmed_my_choices
      expect(DeliveryPartner.find_by_name(supplier_name)).not_to be_nil
    end

    it "Shows an error if the name is blank" do
      when_I_choose_a_supplier_name("")

      # Then
      expect(response).to render_template(:new)
      expect(response.body).to include("Enter a name")
    end
  end

  describe "GET /admin/suppliers/new/supplier-type" do
    it "renders the new_supplier_type template" do
      given_I_have_chosen_supplier_name(supplier_name)

      # When
      get "/admin/suppliers/new/supplier-type"

      # Then
      expect(response).to render_template(:new_supplier_type)
    end
  end

  describe "POST /admin/suppliers/new/supplier-type" do
    before do
      given_I_have_chosen_supplier_name(supplier_name)
    end

    it "redirects when lead provider is selected" do
      when_I_choose_a_lead_provider_type

      # Then
      expect(response).to redirect_to("/admin/suppliers/new/lead-provider/choose-cip")
    end

    it "redirects when delivery partner is selected" do
      when_I_choose_a_delivery_partner_type

      # Then
      expect(response).to redirect_to("/admin/suppliers/new/delivery-partner/choose-lps")
    end

    it "shows an error when nothing is selected" do
      post "/admin/suppliers/new/supplier-type", params: { new_supplier_form: { type: "" } }

      expect(response).to render_template(:new_supplier_type)
      expect(response.body).to include("Choose one")
    end
  end
end
