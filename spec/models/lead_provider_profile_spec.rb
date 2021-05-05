# frozen_string_literal: true

require "rails_helper"

RSpec.describe LeadProviderProfile, type: :model do
  it "enables paper trail" do
    is_expected.to be_versioned
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:lead_provider) }
  end

  describe ".create_lead_provider_user" do
    let(:name) { Faker::Name.name }
    let(:email) { Faker::Internet.email }
    let(:lead_provider) { create(:lead_provider) }
    let(:start_url) { "www.example.com" }
    let(:created_user) { User.find_by(email: email) }

    it "creates a lead provider user" do
      expect {
        LeadProviderProfile.create_lead_provider_user(name, email, lead_provider, start_url)
      }.to change { LeadProviderProfile.count }.by(1)
    end

    it "creates a user with the correct details" do
      LeadProviderProfile.create_lead_provider_user(name, email, lead_provider, start_url)

      expect(created_user.present?).to be(true)
      expect(created_user.full_name).to eql(name)
    end

    it "sends an email to the new user" do
      allow(LeadProviderMailer).to receive(:welcome_email).and_call_original
      LeadProviderProfile.create_lead_provider_user(name, email, lead_provider, start_url)

      expect(LeadProviderMailer).to have_received(:welcome_email)
                                .with(user: created_user, lead_provider_name: lead_provider.name, start_url: start_url)
    end
  end
end
