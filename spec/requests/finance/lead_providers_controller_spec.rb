# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Lead Providers for Finance users", type: :request do
  let(:finance_user) { create(:user, :finance) }
  let!(:ecf_lead_providers) { create_list(:lead_provider, 5, :contract) }
  let(:ecf_lead_provider) { ecf_lead_providers.first }

  before do
    sign_in finance_user
  end

  describe "GET /finance/lead-providers" do
    it "renders the index template" do
      get "/finance/lead-providers"

      expect(response).to render_template("finance/lead_providers/index")
      expect(assigns(:ecf_lead_providers)).to eq(ecf_lead_providers)
    end
  end

  describe "GET /finance/lead-providers/{:id}" do
    it "renders the ECF payment breakdown" do
      get "/finance/lead-providers/#{ecf_lead_provider.id}"

      expect(response).to render_template("finance/lead_providers/show")
      assigns(:ecf_lead_provider).should eq(ecf_lead_provider)
    end
  end
end
