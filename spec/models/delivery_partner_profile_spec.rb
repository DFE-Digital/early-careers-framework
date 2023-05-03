# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeliveryPartnerProfile, type: :model do
  it "enables paper trail" do
    is_expected.to be_versioned
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:delivery_partner) }
  end

  describe ".create_delivery_partner_user" do
    let(:name) { Faker::Name.name }
    let(:email) { Faker::Internet.email }
    let(:delivery_partner) { create(:delivery_partner) }
    let(:created_user) { User.find_by(email:) }
    let(:created_delivery_partner_profile) { DeliveryPartnerProfile.find_by!(user: created_user) }

    it "creates a delivery partner user" do
      expect {
        DeliveryPartnerProfile.create_delivery_partner_user(name, email, delivery_partner)
      }.to change { DeliveryPartnerProfile.count }.by(1)
    end

    it "creates a user with the correct details" do
      DeliveryPartnerProfile.create_delivery_partner_user(name, email, delivery_partner)

      expect(created_user).to be_present
      expect(created_user.full_name).to eql(name)
    end

    it "sends an email to the new user" do
      allow(DeliveryPartnerProfileMailer).to receive(:welcome).and_call_original

      DeliveryPartnerProfile.create_delivery_partner_user(name, email, delivery_partner)

      expect(DeliveryPartnerProfileMailer).to have_received(:welcome).with(created_delivery_partner_profile)
    end
  end
end
