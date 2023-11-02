# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeliveryPartnerProfiles::SearchQuery do
  describe "#call" do
    let(:user_a) { create(:user, email: "user_a@nothing.com", full_name: "User A") }
    let(:user_b) { create(:user, email: "user_c@nothing.com", full_name: "User B") }
    let(:user_c) { create(:user, email: "user_b@nothing.com", full_name: "User C") }
    let(:delivery_partner) { create(:delivery_partner, name: "Test") }
    let!(:delivery_partner_profile_a) { create(:delivery_partner_profile, delivery_partner:, user: user_a) }
    let!(:delivery_partner_profile_b) { create(:delivery_partner_profile, delivery_partner:, user: user_b) }
    let!(:delivery_partner_profile_c) { create(:delivery_partner_profile, delivery_partner:, user: user_c) }

    subject { described_class.new(query:).call }

    context "when the query includes part of the name of a user" do
      let(:query) { "A" }

      it "searches users by name" do
        expect(subject).to match_array([delivery_partner_profile_a])
      end
    end

    context "when the query includes part of the email of a user" do
      let(:query) { "user_a@" }

      it "searches users by email" do
        expect(subject).to match_array([delivery_partner_profile_a])
      end
    end

    context "when the query includes part of the delivery partner name of a user" do
      let(:query) { "Test" }

      it "searches users by delivery partner name" do
        expect(subject).to match_array([delivery_partner_profile_a, delivery_partner_profile_b, delivery_partner_profile_c])
      end
    end
  end
end
