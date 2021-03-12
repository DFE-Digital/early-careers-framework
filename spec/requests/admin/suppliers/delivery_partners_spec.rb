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

  describe "GET /admin/suppliers/new/delivery-partner/choose-name" do
    it "renders the new template" do
      get "/admin/suppliers/new/delivery-partner/choose-name"

      expect(response).to render_template("admin/suppliers/delivery_partners/choose_name")
    end
  end

  describe "POST /admin/suppliers/new/delivery-partner/choose-name" do
    it "redirects to the choose lps page" do
      when_I_choose_a_delivery_partner_name(delivery_partner_name)

      expect(response).to redirect_to("/admin/suppliers/new/delivery-partner/choose-lps")
    end

    it "Sets the correct name" do
      when_I_choose_a_delivery_partner_name(delivery_partner_name)

      # Then
      given_I_have_chosen_lps_and_cohorts([lead_provider], { lead_provider => [cohort] })
      given_I_have_confirmed_my_choices
      expect(DeliveryPartner.find_by_name(delivery_partner_name)).not_to be_nil
    end

    it "Shows an error if the name is blank" do
      when_I_choose_a_delivery_partner_name("")

      # Then
      expect(response).to render_template("admin/suppliers/delivery_partners/choose_name")
      expect(response.body).to include("Enter a name")
    end
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
      given_I_have_chosen_delivery_partner_name(delivery_partner_name)
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
      given_I_have_chosen_delivery_partner_name(delivery_partner_name)
      given_I_have_chosen_lps_and_cohorts([lead_provider], { lead_provider => [cohort] })
    end

    it "redirects to the list of providers on success" do
      when_I_confirm_my_choices

      expect(response).to redirect_to("/admin/suppliers")
      expect(flash[:success]).to eql({ title: "Success", heading: "Delivery partner created", content: "" })
    end

    it "creates a new delivery partner" do
      expect {
        when_I_confirm_my_choices
      }.to change { DeliveryPartner.count }.by(1)
    end
  end

  describe "GET /admin/suppliers/delivery-partners/{delivery_partner.id}/edit" do
    it "renders the edit template" do
      get "/admin/suppliers/delivery-partners/#{delivery_partner.id}/edit"
      expect(response).to render_template("admin/suppliers/delivery_partners/edit")
      expect(response.body).to include(CGI.escapeHTML(delivery_partner.name))
    end
  end

  describe "GET /admin/suppliers/delivery-partners/{delivery_partner.id}/delete" do
    it "renders the delete template" do
      get "/admin/suppliers/delivery-partners/#{delivery_partner.id}/delete"
      expect(response).to render_template("admin/suppliers/delivery_partners/delete")
      expect(response.body).to include(CGI.escapeHTML(delivery_partner.name))
    end
  end

  describe "PATCH /admin/suppliers/delivery-partners/{delivery_partner.id}" do
    it "redirects to the suppliers page" do
      patch "/admin/suppliers/delivery-partners/#{delivery_partner.id}", params: { delivery_partner_form: {
        name: delivery_partner.name,
        lead_provider_ids: [lead_provider.id],
        provider_relationship_hashes: [provider_relationship_value(lead_provider, cohort)],
      } }

      expect(response).to redirect_to("/admin/suppliers")
      follow_redirect!
      expect(response.body).to include(CGI.escapeHTML(delivery_partner.name))
    end

    it "update the name of the delivery partner" do
      old_name = delivery_partner.name
      new_name = Faker::Name.name
      patch "/admin/suppliers/delivery-partners/#{delivery_partner.id}", params: { delivery_partner_form: {
        name: new_name,
        lead_provider_ids: [lead_provider.id],
        provider_relationship_hashes: [provider_relationship_value(lead_provider, cohort)],
      } }

      delivery_partner.reload
      expect(delivery_partner.name).to eq new_name
      follow_redirect!
      expect(response.body).to include(CGI.escapeHTML(new_name))
      expect(response.body).not_to include(CGI.escapeHTML(old_name))
    end

    it "updates provider relationships" do
      old_cohort = create(:cohort)
      old_lead_provider = create(:lead_provider, cohorts: [old_cohort])
      ProviderRelationship.create!(delivery_partner: delivery_partner, lead_provider: old_lead_provider, cohort: old_cohort)
      ProviderRelationship.create!(delivery_partner: delivery_partner, lead_provider: lead_provider, cohort: old_cohort)

      patch "/admin/suppliers/delivery-partners/#{delivery_partner.id}", params: { delivery_partner_form: {
        name: delivery_partner.name,
        lead_provider_ids: [lead_provider.id],
        provider_relationship_hashes: [
          # simulate someone unchecking the lead provider without unchecking the nested cohort
          provider_relationship_value(old_lead_provider, old_cohort),
          provider_relationship_value(lead_provider, cohort),
        ],
      } }

      delivery_partner.reload
      expect(delivery_partner.provider_relationships.find_by(lead_provider: old_lead_provider)).to be_nil
      expect(delivery_partner.provider_relationships.with_discarded.find_by(lead_provider: old_lead_provider)).not_to be_nil
      expect(delivery_partner.provider_relationships.find_by(lead_provider: lead_provider, cohort: old_cohort)).to be_nil
      expect(delivery_partner.provider_relationships.with_discarded.find_by(lead_provider: lead_provider, cohort: old_cohort)).not_to be_nil
      expect(delivery_partner.provider_relationships.find_by(lead_provider: lead_provider, cohort: cohort)).not_to be_nil
    end
  end

  describe "DELETE /admin/suppliers/delivery-partners/{delivery_partner.id}" do
    it "marks the delivery partner as deleted" do
      delete "/admin/suppliers/delivery-partners/#{delivery_partner.id}"

      delivery_partner.reload
      expect(delivery_partner.discarded?).to be true
    end

    it "redirects to the suppliers page" do
      delete "/admin/suppliers/delivery-partners/#{delivery_partner.id}"

      expect(response).to redirect_to("/admin/suppliers")
      expect(response.body).not_to include(CGI.escapeHTML(delivery_partner.name))
    end
  end
end
