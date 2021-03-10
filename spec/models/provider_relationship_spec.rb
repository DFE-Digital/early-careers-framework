# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProviderRelationship, type: :model do
  let(:lead_provider) { create(:lead_provider) }
  let(:delivery_partner) { create(:delivery_partner) }
  let(:cohort) { create(:cohort) }
  let!(:provider_relationship) do
    ProviderRelationship.create(lead_provider: lead_provider, delivery_partner: delivery_partner, cohort: cohort)
  end

  it "can be created" do
    expect {
      ProviderRelationship.create(
        lead_provider: create(:lead_provider),
        delivery_partner: create(:delivery_partner),
        cohort: create(:cohort),
      )
    }.to change { ProviderRelationship.count }.by(1)
  end

  describe "associations" do
    it { is_expected.to belong_to(:lead_provider) }
    it { is_expected.to belong_to(:delivery_partner) }
    it { is_expected.to belong_to(:cohort) }
  end

  describe "soft delete" do
    describe "scope kept" do
      it "does not include discarded delivery partners" do
        expect {
          delivery_partner.discard!
        }.to change { ProviderRelationship.count }.by(-1)
      end
    end

    describe "scope with_discarded" do
      it "includes discarded delivery partners" do
        expect {
          delivery_partner.discard!
        }.not_to(change { ProviderRelationship.with_discarded.count })
      end
    end
  end

  describe "#kept?" do
    it "is true if the delivery partner is kept" do
      expect(provider_relationship.kept?).to be true
    end

    it "is false if the delivery partner is discarded" do
      delivery_partner.discard!
      expect(provider_relationship.reload.kept?).to be false
    end
  end
end
