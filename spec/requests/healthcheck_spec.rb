# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Healthcheck" do
  describe "GET /healtcheck" do
    let(:git_sha) { "911403d" }
    let(:release_version) { "3.2" }
    let(:migration_version) { ApplicationRecord.connection.migration_context.current_version }
    let(:response_body) { JSON.parse(perform_request.body, symbolize_names: true) }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("SHA") { git_sha }
      allow(ENV).to receive(:[]).with("RELEASE_VERSION") { release_version }
      stub_request(:get, HealthcheckController::NOTIFY_STATUS_API).to_return(status: 200, body: { "status": { "indicator": "none" } }.to_json)
    end

    subject(:perform_request) do
      get healthcheck_path
      response
    end

    context "with a populated database" do
      let!(:school) { create(:school) }
      let!(:schedule) { create(:ecf_schedule) }

      it { is_expected.to be_successful }
      it { expect(response_body[:sha]).to eq(git_sha) }
      it { expect(response_body[:version]).to eq(release_version) }
      it { expect(response_body[:database]).to match({ connected: true, populated: true, migration_version: }) }
      it { expect(response_body[:notify][:incident_status]).to eq("none") }
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
  end
end
