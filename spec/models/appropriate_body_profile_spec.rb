# frozen_string_literal: true

require "rails_helper"

RSpec.describe AppropriateBodyProfile, type: :model do
  it "enables paper trail" do
    is_expected.to be_versioned
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:appropriate_body) }
  end

  describe ".create_appropriate_body_user" do
    let(:name) { Faker::Name.name }
    let(:email) { Faker::Internet.email }
    let(:appropriate_body) { create(:appropriate_body_local_authority) }
    let(:created_user) { User.find_by(email:) }
    let(:created_appropriate_body_profile) { AppropriateBodyProfile.find_by!(user: created_user) }

    it "creates a delivery partner user" do
      expect {
        AppropriateBodyProfile.create_appropriate_body_user(name, email, appropriate_body)
      }.to change { AppropriateBodyProfile.count }.by(1)
    end

    it "creates a user with the correct details" do
      AppropriateBodyProfile.create_appropriate_body_user(name, email, appropriate_body)

      expect(created_user).to be_present
      expect(created_user.full_name).to eql(name)
      expect(created_user).to be_appropriate_body
    end

    it "sends an email to the new user" do
      allow(AppropriateBodyProfileMailer).to receive(:welcome).and_call_original
      AppropriateBodyProfile.create_appropriate_body_user(name, email, appropriate_body)

      expect(AppropriateBodyProfileMailer).to have_received(:welcome).with(created_appropriate_body_profile)
    end
  end
end
