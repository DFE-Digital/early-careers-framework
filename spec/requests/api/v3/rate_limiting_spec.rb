# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API Rate Limiting", type: :request do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:cohort) { Cohort.current || create(:cohort, :current) }
  let(:delivery_partner) { create(:delivery_partner, name: "First Delivery Partner") }
  let!(:provider_relationship) { create(:provider_relationship, cohort:, delivery_partner:, lead_provider:) }

  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token) { "Bearer #{token}" }

  let(:token2) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token2) { "Bearer #{token2}" }

  let(:cache_store) { ActiveSupport::Cache.lookup_store(:file_store, Rails.root.join("tmp/cache/rate_limiting")) }

  before do
    Rack::Attack.cache.store = cache_store
    Rack::Attack.cache.store.clear

    # Reduce the limit to make it easier to test
    Rack::Attack.throttles["API requests by ip"].instance_variable_set(:@limit, 3)

    default_headers[:Authorization] = bearer_token
    expect(Rack::Attack.enabled).to be_truthy
  end

  after do
    Rack::Attack.cache.store.clear
    Rack::Attack.cache.store = Rails.cache
  end

  describe "Rate limiting /api/v3/delivery-partners/{id}" do
    context "When going over limit" do
      it "returns 429 when going over 3 requests within 3 min" do
        3.times do
          get "/api/v3/delivery-partners/#{delivery_partner.id}"
          expect(response).to have_http_status(:success)
        end

        # Should return error
        get "/api/v3/delivery-partners/#{delivery_partner.id}"
        expect(response).to have_http_status(429)
      end
    end

    context "When using a second ApiToken" do
      it "allows second ApiToken requests" do
        3.times do
          get "/api/v3/delivery-partners/#{delivery_partner.id}"
          expect(response).to have_http_status(:success)
        end

        default_headers[:Authorization] = bearer_token2

        3.times do
          get "/api/v3/delivery-partners/#{delivery_partner.id}"
          expect(response).to have_http_status(:success)
        end

        # Should return error
        get "/api/v3/delivery-partners/#{delivery_partner.id}"
        expect(response).to have_http_status(429)
      end
    end
  end
end
