# frozen_string_literal: true

require "rails_helper"

RSpec.describe Migration::ParityCheck::TokenProvider do
  before do
    create_list(:npq_lead_provider, 3)

    allow(Rails).to receive(:env) { environment.inquiry }

    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("PARITY_CHECK_KEYS").and_return(keys.to_json) if keys
  end

  let(:instance) { described_class.new }

  describe "#generate!" do
    subject(:generate) { instance.generate! }

    context "when running in migration" do
      let(:environment) { "migration" }

      context "when the keys are not present" do
        let(:keys) { nil }

        it { expect { generate }.not_to change(ApiToken, :count) }
      end

      context "when the keys are present" do
        let(:keys) do
          NPQLeadProvider.all.each_with_object({}) do |lead_provider, hash|
            hash[lead_provider.id] = SecureRandom.uuid
          end
        end

        it { expect { generate }.to change(ApiToken, :count).by(NPQLeadProvider.count) }

        it "generates valid tokens for each lead provider" do
          generate

          NPQLeadProvider.find_each do |lead_provider|
            cpd_lead_provider = lead_provider.cpd_lead_provider
            token = keys[lead_provider.id]
            expect(ApiToken.find_by_unhashed_token(token).cpd_lead_provider).to eq(cpd_lead_provider)
          end
        end
      end
    end

    context "when not running in migration" do
      let(:environment) { "production" }
      let(:keys) { {} }

      it { expect { generate }.to raise_error(described_class::UnsupportedEnvironmentError, "The parity check functionality is disabled for this environment") }
    end
  end
end
