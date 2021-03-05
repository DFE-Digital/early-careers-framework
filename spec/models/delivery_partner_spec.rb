# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeliveryPartner, type: :model do
  it "can be created" do
    expect {
      DeliveryPartner.create(name: "Delivery Partner")
    }.to change { DeliveryPartner.count }.by(1)
  end

  describe "associations" do
    it { is_expected.to have_many(:provider_relationships) }
    it { is_expected.to have_many(:lead_providers).through(:provider_relationships) }
  end

  describe "soft delete" do
    let!(:delivery_partner) { create(:delivery_partner) }
    it "can be discarded" do
      delivery_partner.discard

      expect(delivery_partner.discarded?).to be true
    end

    it "is not returned in the default scope when discarded" do
      delivery_partner.discard

      expect(DeliveryPartner.all).not_to include(delivery_partner)
    end

    it "is returned in the with_discarded scope when discarded" do
      delivery_partner.discard

      expect(DeliveryPartner.with_discarded).to include(delivery_partner)
    end

    it "does not increase the count when discarded" do
      expect { delivery_partner.discard }.to change { DeliveryPartner.count }.by(-1)
    end
  end
end
