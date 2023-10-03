# frozen_string_literal: true

require "rails_helper"

describe "Rate limiting" do
  let(:ip) { "1.2.3.4" }
  let(:other_ip) { "9.8.7.6" }

  before { default_headers[:REMOTE_ADDR] = ip }

  it_behaves_like "a rate limited endpoint", "csp_reports req/ip", 1.minute do
    def perform_request
      post csp_reports_path, params: {}.to_json
    end

    def change_condition
      default_headers[:REMOTE_ADDR] = other_ip
    end
  end

  context "login attempts" do
    it_behaves_like "a rate limited endpoint", "Login attempts by ip", 20.seconds do
      def perform_request
        post user_session_path
      end

      def change_condition
        default_headers[:REMOTE_ADDR] = other_ip
      end
    end
  end

  it_behaves_like "a rate limited endpoint", "Non-API requests by ip", 5.minutes do
    def perform_request
      get root_path
    end

    def change_condition
      default_headers[:REMOTE_ADDR] = other_ip
    end
  end

  context "api requests" do
    let(:cpd_lead_provider1) { create(:cpd_lead_provider, :with_lead_provider) }
    let(:token1) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider1) }
    let(:bearer_token1) { "Bearer #{token1}" }

    let(:cpd_lead_provider2) { create(:cpd_lead_provider, :with_lead_provider) }
    let(:token2) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider2) }
    let(:bearer_token2) { "Bearer #{token2}" }

    before do
      default_headers[:Authorization] = bearer_token1
    end

    it_behaves_like "a rate limited endpoint", "API requests by ip", 5.minutes do
      def perform_request
        get "/api/v3/participants/ecf"
      end

      def change_condition
        default_headers[:Authorization] = bearer_token2
      end
    end
  end
end
