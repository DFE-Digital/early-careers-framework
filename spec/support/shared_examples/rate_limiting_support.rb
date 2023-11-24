# frozen_string_literal: true

require "dfe/analytics/rspec/matchers"

shared_examples "a rate limited endpoint", rack_attack: true do |desc, period|
  describe desc do
    let(:limit) { 2 }

    subject { response }

    before do
      memory_store = ActiveSupport::Cache.lookup_store(:memory_store)
      allow(Rack::Attack.cache).to receive(:store) { memory_store }

      allow(Rack::Attack.throttles[desc]).to receive(:limit) { limit }

      allow(Rails.logger).to receive(:warn)

      freeze_time

      request_count.times { perform_request }
    end

    context "when fewer than rate limit" do
      let(:request_count) { limit - 1 }

      it { is_expected.to have_http_status(:success) }
    end

    context "when more than rate limit" do
      let(:request_count) { limit + 1 }

      it { is_expected.to have_http_status(:too_many_requests) }

      it { expect { perform_request }.not_to have_sent_analytics_event_types(:web_request) }

      context "when the dfe_analytics feature is enabled" do
        before { FeatureFlag.activate(:dfe_analytics) }

        it { expect { perform_request }.to have_sent_analytics_event_types(:web_request) }
      end

      it "logs a warning" do
        expect(Rails.logger).to have_received(:warn).with(
          %r{\[rack-attack\] Throttled request [a-zA-Z0-9]{20} from #{Regexp.escape(request.remote_ip)} to '#{request.path}'},
        )
      end

      it "allows another request when the time restriction has passed" do
        travel(period + 10.seconds)
        perform_request
        is_expected.to have_http_status(:success)
      end

      it "allows another request if the condition changes" do
        change_condition
        perform_request
        is_expected.to have_http_status(:success)
      end
    end
  end
end
