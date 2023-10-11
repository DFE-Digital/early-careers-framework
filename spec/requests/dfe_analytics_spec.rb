# frozen_string_literal: true

require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.describe "DfE Analytics", type: :request do
  it "does not send DFE Analytics web request events" do
    expect { get root_path }.not_to have_sent_analytics_event_types(:web_request)
  end

  it "does not send DFE Analytics entity events" do
    Cohort.create!(start_year: 2005)
    expect(:create_entity).not_to have_been_enqueued_as_analytics_events
  end

  context "when the dfe_analytics feature is enabled" do
    before { FeatureFlag.activate(:dfe_analytics) }

    it "sends DFE Analytics web request event" do
      expect { get root_path }.to have_sent_analytics_event_types(:web_request)
    end

    it "sends DFE Analytics entity events" do
      Cohort.create!(start_year: 2005)
      expect(:create_entity).to have_been_enqueued_as_analytics_events
    end

    it "does not send a web request event for GET /check" do
      expect { get check_path }.not_to have_sent_analytics_event_types(:web_request)
    end

    context "with lead provider API requests" do
      let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
      let(:token)             { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
      let(:bearer_token)      { "Bearer #{token}" }

      it "sends DFE Analytics web request event" do
        default_headers[:Authorization] = bearer_token

        expect { get "/api/v3/participants/ecf" }.to have_sent_analytics_event_types(:web_request)
      end
    end

    context "with NPQ registration application API requests" do
      let!(:npq_application) { create(:npq_application) }
      let(:token)             { NPQRegistrationApiToken.create_with_random_token! }
      let(:bearer_token)      { "Bearer #{token}" }

      it "sends DFE Analytics web request event" do
        default_headers[:Authorization] = bearer_token

        expect { get "/api/v1/npq-profiles/#{npq_application.id}" }.to have_sent_analytics_event_types(:web_request)
      end
    end
  end
end
