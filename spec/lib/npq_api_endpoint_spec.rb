# frozen_string_literal: true

require "rails_helper"
require "npq_api_endpoint"

RSpec.describe NpqApiEndpoint do
  before { Rails.application.config.separation = nil }

  describe ".matches?" do
    let(:request) { instance_double(ActionDispatch::Request) }

    it "returns true by default" do
      expect(described_class.matches?(request)).to be_truthy
    end

    describe "when disable_npq_endpoints is true" do
      before { Rails.application.config.separation = { disable_npq_endpoints: true } }

      it "returns false" do
        expect(described_class.matches?(request)).to be_falsy
      end
    end

    describe "when disable_npq_endpoints is false" do
      before { Rails.application.config.separation = { disable_npq_endpoints: false } }

      it "returns true" do
        expect(described_class.matches?(request)).to be_truthy
      end
    end
  end

  describe ".disable_npq_endpoints?" do
    it "returns false by default" do
      expect(described_class.disable_npq_endpoints?).to be_falsy
    end

    describe "when disable_npq_endpoints is true" do
      before { Rails.application.config.separation = { disable_npq_endpoints: true } }

      it "returns true" do
        expect(described_class.disable_npq_endpoints?).to be_truthy
      end
    end

    describe "when disable_npq_endpoints is false" do
      before { Rails.application.config.separation = { disable_npq_endpoints: false } }

      it "returns false" do
        expect(described_class.disable_npq_endpoints?).to be_falsy
      end
    end
  end
end
