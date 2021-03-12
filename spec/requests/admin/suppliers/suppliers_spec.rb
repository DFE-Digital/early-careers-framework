# frozen_string_literal: true

require "rails_helper"
include NewSupplierHelper

RSpec.describe "Admin::Suppliers", type: :request do
  before do
    admin_user = create(:user, :admin)
    sign_in admin_user
  end

  describe "GET /admin/suppliers" do
    let!(:lead_provider) { create(:lead_provider) }
    let!(:delivery_partner) { create(:delivery_partner) }

    it "renders the suppliers index template" do
      get "/admin/suppliers"
      expect(response).to render_template("admin/suppliers/suppliers/index")
    end

    it "lists delivery partners and lead providers" do
      get "/admin/suppliers"
      expect(response.body).to include(CGI.escapeHTML(lead_provider.name), CGI.escapeHTML(delivery_partner.name))
    end
  end
end
