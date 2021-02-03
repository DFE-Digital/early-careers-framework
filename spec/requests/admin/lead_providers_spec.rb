# frozen_string_literal: true

require "rails_helper"
include NewSupplierHelper

RSpec.describe "Admin::LeadProviders", type: :request do
  let(:lead_provider_name) { Faker::Company.name }
  let(:cip) { create(:core_induction_programme) }
  let(:cohort) { create(:cohort) }

  before do
    admin_user = create(:user, :admin)
    sign_in admin_user
  end

  describe "GET /admin/suppliers/new/lead-provider/choose-cip" do
    it "renders the choose_cip template" do
      # When
      get "/admin/suppliers/new/lead-provider/choose-cip"

      # Then
      expect(response).to render_template(:choose_cip)
    end
  end

  describe "POST /admin/suppliers/new/lead-provider/choose-cip" do
    before do
      given_I_have_chosen_supplier_name(lead_provider_name)
      given_I_have_chosen_lead_provider_type
    end

    it "redirects to the cohorts page" do
      when_I_choose_a_cip(cip)

      # Then
      expect(response).to redirect_to("/admin/suppliers/new/lead-provider/choose-cohorts")
    end

    it "sets the correct CIP" do
      when_I_choose_a_cip(cip)

      # Then
      given_I_have_chosen_cohorts([cohort])
      given_I_have_confirmed_my_lead_provider_choices

      new_lead_provider = LeadProvider.order(:created_at).last
      expect(new_lead_provider.core_induction_programmes).to contain_exactly(cip)
    end

    it "displays an error when no cip is selected" do
      # When
      get "/admin/suppliers/new/lead-provider/choose-cip"
      post "/admin/suppliers/new/lead-provider/choose-cip", params: { lead_provider_form: {} }

      # Then
      expect(response).to render_template(:choose_cip)
      expect(response.body).to include("Choose one")
    end
  end

  describe "GET /admin/suppliers/new/lead-provider/choose-cohorts" do
    it "renders the choose_cohorts template" do
      # When
      get "/admin/suppliers/new/lead-provider/choose-cohorts"

      # Then
      expect(response).to render_template(:choose_cohorts)
    end
  end

  describe "POST /admin/suppliers/new/lead-provider/choose-cohorts" do
    before do
      given_I_have_chosen_supplier_name(lead_provider_name)
      given_I_have_chosen_lead_provider_type
      given_I_have_chosen_cip(cip)
    end

    it "redirects to the review page" do
      when_I_choose_cohorts([cohort])

      # Then
      expect(response).to redirect_to("/admin/suppliers/new/lead-provider/review")
    end

    it "displays an error when no cohorts are selected" do
      # When
      get "/admin/suppliers/new/lead-provider/choose-cohorts"
      post "/admin/suppliers/new/lead-provider/choose-cohorts", params: { lead_provider_form: {} }

      # Then
      expect(response).to render_template(:choose_cohorts)
      expect(response.body).to include("Choose one or more")
    end

    it "sets the correct cohorts" do
      when_I_choose_cohorts([cohort])

      # Then
      given_I_have_confirmed_my_lead_provider_choices

      new_lead_provider = LeadProvider.order(:created_at).last
      expect(new_lead_provider.cohorts).to contain_exactly(cohort)
    end
  end

  describe "POST /admin/suppliers/new/lead_provider" do
    before do
      given_I_have_chosen_supplier_name(lead_provider_name)
      given_I_have_chosen_lead_provider_type
      given_I_have_chosen_cip(cip)
      given_I_have_chosen_cohorts([cohort])
    end

    it "redirects to the success message on success" do
      # When
      when_I_confirm_my_lead_provider_choices

      # Then
      new_lead_provider = LeadProvider.order(:created_at).last
      expect(response).to redirect_to("/admin/suppliers/new/lead-provider/success?lead_provider=#{new_lead_provider.id}")
    end

    it "creates a new lead provider" do
      expect {
        when_I_confirm_my_lead_provider_choices
      }.to change { LeadProvider.count }.by(1)
    end

    it "creates a lead provider with the correct name" do
      # When
      when_I_confirm_my_lead_provider_choices

      # Then
      expect(LeadProvider.find_by_name(lead_provider_name)).not_to be_nil
    end
  end
end
