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
  end

  context "login attempts" do
    it_behaves_like "a rate limited endpoint", "Login attempts by ip", 20.seconds do
      def perform_request
        post user_session_path
      end

      def change_condition
        set_request_ip(other_ip)
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
  end

  [
    [:with_lead_provider, "/api/v3/participants/ecf"],
    [:with_npq_lead_provider, "/api/v3/participants/npq"],
  ].each do |(lead_provider_trait, provider_path)|
    context "api requests (#{lead_provider_trait})" do
      let(:cpd_lead_provider1) { create(:cpd_lead_provider, lead_provider_trait) }
      let(:token1) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider1) }
      let(:bearer_token1) { "Bearer #{token1}" }

      let(:cpd_lead_provider2) { create(:cpd_lead_provider, lead_provider_trait) }
      let(:token2) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider2) }
      let(:bearer_token2) { "Bearer #{token2}" }

      let(:path) { provider_path }

      before { set_auth_token(bearer_token1) }

      it_behaves_like "a rate limited endpoint", "API requests by ip", 5.minutes do
        def perform_request
          get path
        end

        def change_condition
          set_auth_token(bearer_token2)
        end
      end
    end
  end

  context "api requests for NPQ registration" do
    let(:token1) { NPQRegistrationApiToken.create_with_random_token! }
    let(:bearer_token1) { "Bearer #{token1}" }

    let(:token2) { NPQRegistrationApiToken.create_with_random_token! }
    let(:bearer_token2) { "Bearer #{token2}" }

    let(:application) { create(:npq_application) }

    before { set_auth_token(bearer_token1) }

    it_behaves_like "a rate limited endpoint", "API requests by ip", 5.minutes do
      def perform_request
        get api_v1_npq_profile_path(application)
      end

      def change_condition
        set_auth_token(bearer_token2)
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
