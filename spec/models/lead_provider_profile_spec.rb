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
    let(:created_user) { User.find_by(email:) }
    let(:existing_user) { create(:user) }

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

    it "creates lead_provider_profile for an existing user" do
      expect(existing_user.lead_provider).to eql(nil)
      LeadProviderProfile.create_lead_provider_user(existing_user.full_name, existing_user.email, lead_provider, start_url)

      existing_user.reload
      expect(existing_user.lead_provider).to eql(lead_provider)
    end

    it "sends an email to the new user" do
      allow(LeadProviderMailer).to receive(:with).and_call_original

      LeadProviderProfile.create_lead_provider_user(name, email, lead_provider, start_url)

      expect(LeadProviderMailer).to have_received(:with).once.with(any_args)
    end
  end
end
