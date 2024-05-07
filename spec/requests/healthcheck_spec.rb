# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Healthcheck" do
  describe "GET /healtcheck" do
    let(:git_sha) { "911403d" }
    let(:release_version) { "3.2" }
    let(:migration_version) { ApplicationRecord.connection.migration_context.current_version }

    let(:sidekiq_job_count) { 1 }
    let(:sidekiq_errors) { 2 }
    let(:sidekiq_failed) { 3 }
    let(:sidekiq_queue) { instance_double(Sidekiq::Queue, size: sidekiq_job_count) }
    let(:sidekiq_retries) { instance_double(Sidekiq::RetrySet, size: sidekiq_errors) }
    let(:sidekiq_deadset) { instance_double(Sidekiq::DeadSet, size: sidekiq_failed, to_a: []) }
    let(:puma_stats) { { backlog: 0, running: 5 } }

    let(:response_body) { JSON.parse(perform_request.body, symbolize_names: true) }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("SHA") { git_sha }
      allow(ENV).to receive(:[]).with("RELEASE_VERSION") { release_version }

      allow(Sidekiq::Queue).to receive(:all).and_return([sidekiq_queue])
      allow(Sidekiq::RetrySet).to receive(:new).and_return(sidekiq_retries)
      allow(Sidekiq::DeadSet).to receive(:new).and_return(sidekiq_deadset)

      stub_request(:get, HealthcheckController::NOTIFY_STATUS_API).to_return(status: 200, body: { status: { indicator: "none" } }.to_json)
      allow(Puma).to receive(:stats).and_return(puma_stats.to_json)
    end

    subject(:perform_request) do
      get healthcheck_path
      response
    end

    context "when the database is populated" do
      let!(:school) { create(:school) }
      let!(:schedule) { create(:ecf_schedule) }

      it { is_expected.to be_successful }
      it { expect(response_body[:sha]).to eq(git_sha) }
      it { expect(response_body[:version]).to eq(release_version) }
      it { expect(response_body[:database]).to match({ connected: true, populated: true, migration_version: }) }

      it { expect(response_body[:sidekiq][:job_count]).to eq(sidekiq_job_count) }
      it { expect(response_body[:sidekiq][:errors]).to eq(sidekiq_errors) }
      it { expect(response_body[:sidekiq][:failed]).to eq(sidekiq_failed) }
      it { expect(response_body[:sidekiq][:sidekiq_last_failure]).to be_nil }

      it { expect(response_body[:notify][:incident_status]).to eq("none") }
      it { expect(response_body[:puma]).to eq(puma_stats) }
    end

    context "when the database is not connected" do
      context "when ApplicationRecord#connected? raises an error" do
        before { allow(ApplicationRecord).to receive(:connected?).and_raise(RuntimeError) }

        it { is_expected.to be_server_error }
        it { expect(response_body[:database]).to include({ connected: false, populated: false }) }
      end

      context "when ApplicationRecord#connected? returns false" do
        before { allow(ApplicationRecord).to receive(:connected?).and_return(false) }

        it { is_expected.to be_server_error }
        it { expect(response_body[:database]).to include({ connected: false, populated: false }) }
      end
    end

    context "when the database is not populated" do
      it { is_expected.to be_server_error }
      it { expect(response_body[:database]).to include({ connected: true, populated: false }) }

      context "when the environment supports refreshing the database via a GitHub action" do
        before { allow(Rails).to receive(:env) { "migration".inquiry } }

        it { is_expected.to be_successful }
        it { expect(response_body[:database]).to include({ connected: true, populated: true }) }
      end
    end

    context "when notify API is down" do
      before { stub_request(:get, HealthcheckController::NOTIFY_STATUS_API).to_return(status: 500) }
      it { is_expected.to be_server_error }
      it { expect(response_body[:notify][:incident_status]).to eq("Status request failed") }
    end

    context "when notify has an incident" do
      before { stub_request(:get, HealthcheckController::NOTIFY_STATUS_API).to_return(status: 200, body: { status: { indicator: "incident_in_progress" } }.to_json) }
      it { is_expected.to be_server_error }
      it { expect(response_body[:notify][:incident_status]).to eq("incident_in_progress") }
    end

    context "when puma stats are unavailable" do
      before { allow(Puma).to receive(:stats).and_raise(StandardError) }

      it { is_expected.to be_server_error }
      it { expect(response_body[:puma]).to eq("FAIL") }
    end
  end
end
