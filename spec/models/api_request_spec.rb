# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApiRequest, type: :model do
  subject { build(:api_request) }

  describe "associations" do
    it { is_expected.to belong_to(:cpd_lead_provider).optional }
  end

  describe "scopes" do
    describe "unprocessable_entities" do
      let!(:api_request_one) { create(:api_request, :success) }
      let!(:api_request_two) { create(:api_request, :unprocessable_entity) }

      it "returns unprocessable entities records only" do
        expect(described_class.unprocessable_entities).to eq([api_request_two])
      end
    end

    describe "errors" do
      let!(:api_request_one) { create(:api_request, :errors) }
      let!(:api_request_two) { create(:api_request, :success) }

      it "returns unprocessable entities records only" do
        expect(described_class.errors).to eq([api_request_one])
      end
    end

    describe "successful" do
      let!(:api_request_one) { create(:api_request, :success) }
      let!(:api_request_two) { create(:api_request, :unprocessable_entity) }

      it "returns unprocessable entities records only" do
        expect(described_class.successful).to eq([api_request_one])
      end
    end
  end
end
