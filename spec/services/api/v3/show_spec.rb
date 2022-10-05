# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V3::DeliveryPartners::Show do
  describe "#delivery_partners" do
    let(:cpd_lead_provider) { create(:cpd_lead_provider, lead_provider:) }
    let(:lead_provider) { create(:lead_provider) }
    let(:cohort) { Cohort.current || create(:cohort, :current) }
    let(:delivery_partner) { create(:delivery_partner, name: "First Delivery Partner") }
    let!(:provider_relationship) { create(:provider_relationship, cohort:, delivery_partner:, lead_provider:) }

    let(:params) { {} }

    subject { described_class.new(lead_provider:, params:) }

    context "with correct params" do
      let(:params) { { id: delivery_partner.id } }

      it "returns a specific delivery partners" do
        expect(subject.delivery_partner).to eq(delivery_partner)
      end
    end

    context "with incorrect params" do
      let(:params) { { id: SecureRandom.uuid } }

      it "returns a specific delivery partners" do
        expect(subject.delivery_partner).to be_nil
      end
    end

    context "with no params" do
      it "returns no delivery partners" do
        expect(subject.delivery_partner).to be_nil
      end
    end
  end
end
