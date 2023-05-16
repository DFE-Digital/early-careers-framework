# frozen_string_literal: true

require "rails_helper"

RSpec.describe ValidLeadProviderApiRoute do
  let(:request) { instance_double(ActionDispatch::Request, params:) }

  context "for an existing version" do
    let(:params) { { api_version: "v1" } }

    it "is a valid api version" do
      expect(described_class.matches?(request)).to be(true)
    end
  end

  context "for an empty version" do
    let(:params) { {} }

    it "is not a valid api version" do
      expect(described_class.matches?(request)).to be(false)
    end
  end

  context "for an unknown version" do
    let(:params) { { api_version: "v3.1" } }

    it "is not a valid api version" do
      expect(described_class.matches?(request)).to be(false)
    end
  end
end
