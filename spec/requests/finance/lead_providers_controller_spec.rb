# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Lead Providers for Finance users", type: :request do
  let(:finance_user) { create(:user, :finance) }
  let!(:lead_providers) { create_list(:lead_provider, 5) }

  before do
    sign_in finance_user
  end

  describe "GET /finance/lead-providers" do
    it "renders the index template" do
      get "/finance/lead-providers"

      expect(response).to render_template("finance/lead_providers/index")
      expect(assigns(:lead_providers)).to eq(lead_providers)
    end
  end
end
