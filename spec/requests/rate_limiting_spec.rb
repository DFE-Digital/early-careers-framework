# frozen_string_literal: true

require "rails_helper"

describe "Rate limiting" do
  let(:ip) { "1.2.3.4" }
  let(:other_ip) { "9.8.7.6" }

  before { set_request_ip(ip) }

  it_behaves_like "a rate limited endpoint", "csp_reports req/ip", 1.minute do
    def perform_request
      post csp_reports_path, params: {}.to_json
    end

    def change_condition
      set_request_ip(other_ip)
    end

    def current_user
      nil
    end
  end

  context "login attempts" do
    it_behaves_like "a rate limited endpoint", "Login attempts by ip", 20.seconds do
      def perform_request
        post user_session_path
      end

      def change_condition
        set_request_ip(other_ip)
      end

      def current_user
        nil
      end
    end
  end

  it_behaves_like "a rate limited endpoint", "Non-API requests by ip", 5.minutes do
    def perform_request
      get root_path
    end

    def change_condition
      set_request_ip(other_ip)
    end

    def current_user
      nil
    end
  end

  context "api requests for ECF" do
    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
    let(:token1) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
    let(:bearer_token1) { "Bearer #{token1}" }

    let(:cpd_lead_provider2) { create(:cpd_lead_provider, :with_lead_provider) }
    let(:token2) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
    let(:bearer_token2) { "Bearer #{token2}" }

    let(:path) { "/api/v3/participants/ecf" }

    before { set_auth_token(bearer_token1) }

    it_behaves_like "a rate limited endpoint", "API requests by ip", 5.minutes do
      def perform_request
        get path
      end

      def change_condition
        set_auth_token(bearer_token2)
      end

      def current_user
        cpd_lead_provider
      end
    end
  end

  def set_request_ip(request_ip)
    default_headers[:REMOTE_ADDR] = request_ip
  end

  def set_auth_token(token)
    default_headers[:Authorization] = token
  end
end
