# frozen_string_literal: true

require "rails_helper"
require "npq_api_endpoint_route"

RSpec.describe NpqApiEndpointRoute do
  let(:request) { instance_double(ActionDispatch::Request) }

  describe ".matches?" do
    it "returns true by default" do
      expect(described_class.matches?(request)).to be_truthy
    end

    describe "when disable_npq_endpoints is true" do
      before { FeatureFlag.activate(:disable_npq_endpoints) }

      it "returns false" do
        expect(described_class.matches?(request)).to be_falsy
      end
    end

    describe "when disable_npq_endpoints is false" do
      before { FeatureFlag.deactivate(:disable_npq_endpoints) }

      it "returns true" do
        expect(described_class.matches?(request)).to be_truthy
      end
    end
  end
end
