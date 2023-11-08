# frozen_string_literal: true

require "rails_helper"

RSpec.describe AppropriateBodyProfiles::SearchQuery do
  describe "#call" do
    let(:user_a) { create(:user, email: "user_a@nothing.com", full_name: "User A") }
    let(:user_b) { create(:user, email: "user_c@nothing.com", full_name: "User B") }
    let(:user_c) { create(:user, email: "user_b@nothing.com", full_name: "User C") }
    let(:appropriate_body) { create(:appropriate_body_local_authority, name: "Test") }
    let!(:appropriate_body_profile_a) { create(:appropriate_body_profile, appropriate_body:, user: user_a) }
    let!(:appropriate_body_profile_b) { create(:appropriate_body_profile, appropriate_body:, user: user_b) }
    let!(:appropriate_body_profile_c) { create(:appropriate_body_profile, appropriate_body:, user: user_c) }

    subject { described_class.new(query:).call }

    context "when the query includes part of the name of a user" do
      let(:query) { "A" }

      it "searches users by name" do
        expect(subject).to eq([appropriate_body_profile_a])
      end
    end

    context "when the query includes part of the email of a user" do
      let(:query) { "user_a@" }

      it "searches users by email" do
        expect(subject).to eq([appropriate_body_profile_a])
      end
    end

    context "when the query includes part of the appropriate body name of a user" do
      let(:query) { "Test" }

      it "searches users by appropriate body name" do
        expect(subject).to eq([appropriate_body_profile_a, appropriate_body_profile_b, appropriate_body_profile_c])
      end
    end

    context "when the query includes no matches" do
      let(:query) { "XYZW123" }

      it "returns empty" do
        expect(subject).to be_empty
      end
    end

    context "when the query is blank" do
      let(:query) { "" }

      it "returns all records" do
        expect(subject).to eq([appropriate_body_profile_a, appropriate_body_profile_b, appropriate_body_profile_c])
      end
    end
  end
end
