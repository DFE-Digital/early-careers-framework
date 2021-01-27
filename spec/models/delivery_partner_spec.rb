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
    it { is_expected.to have_many(:delivery_partner_profiles) }
    it { is_expected.to have_many(:users).through(:delivery_partner_profiles) }
  end
end
