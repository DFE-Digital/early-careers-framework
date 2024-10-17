# frozen_string_literal: true

require "rails_helper"
require "npq_api_endpoint"

RSpec.describe NpqApiEndpoint do
  describe ".matches?" do
    let(:request) { instance_double(ActionDispatch::Request) }

    it "returns true by default" do
      expect(described_class.matches?(request)).to be_truthy
    end

    context "when 'disable_npq' feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "returns false" do
        expect(described_class.matches?(request)).to be_falsy
      end
    end

    context "when 'disable_npq' feature is not active" do
      before { FeatureFlag.deactivate(:disable_npq) }

      it "returns true" do
        expect(described_class.matches?(request)).to be_truthy
      end
    end
  end

  describe ".disabled?" do
    it "returns false by default" do
      expect(described_class.disabled?).to be_falsy
    end

    context "when 'disable_npq' feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "returns true" do
        expect(described_class.disabled?).to be_truthy
      end
    end

    context "when 'disable_npq' feature is not active" do
      before { FeatureFlag.deactivate(:disable_npq) }

      it "returns false" do
        expect(described_class.disabled?).to be_falsy
      end
    end
  end
end
