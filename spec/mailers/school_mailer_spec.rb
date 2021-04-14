# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolMailer, type: :mailer do
  describe "#nomination_email" do
    let(:token) { "fedd83c06d5747f1" }
    let(:primary_contact_email) { "contact@example.com" }
    let(:nomination_url) { "https://ecf-dev.london.cloudapps/nominations?token=#{token}" }

    let(:nomination_email) do
      SchoolMailer.nomination_email(
        recipient: primary_contact_email,
        nomination_url: nomination_url,
        reference: token,
        school_name: "Great Ouse Academy",
      ).deliver_now
    end

    it "renders the right headers" do
      expect(nomination_email.from).to eq(["mail@example.com"])
      expect(nomination_email.to).to eq([primary_contact_email])
    end
  end

  describe "#nomination_email_confirmation" do
    let(:school) { create(:school) }
    let(:user) { create(:user, :induction_coordinator) }
    let(:start_url) { "https://ecf-dev.london.cloudapps" }

    let(:nomination_confirmation_email) do
      SchoolMailer.nomination_confirmation_email(
        user: user,
        school: school,
        start_url: start_url,
      ).deliver_now
    end

    it "renders the right headers" do
      expect(nomination_confirmation_email.to).to eq([user.email])
      expect(nomination_confirmation_email.from).to eq(["mail@example.com"])
    end
  end

  describe "#partnership_notification_email" do
    let(:recipient) { Faker::Internet.email }
    let(:provider_name) { Faker::Company.name }
    let(:start_url) { "https://www.example.com" }
    let(:challenge_url) { "https://www.example.com?token=abc123" }

    let(:partnership_notification_email) do
      SchoolMailer.partnership_notification_email(
        recipient: recipient,
        provider_name: provider_name,
        start_url: start_url,
        challenge_url: start_url,
      )
    end

    it "renders the right headers" do
      expect(partnership_notification_email.from).to eq(["mail@example.com"])
      expect(partnership_notification_email.to).to eq([recipient])
    end
  end

  describe "#send_partnership_notification_email" do
    before(:all) do
      RSpec::Mocks.configuration.verify_partial_doubles = false
    end

    after(:all) do
      RSpec::Mocks.configuration.verify_partial_doubles = true
    end

    let(:recipient) { Faker::Internet.email }
    let(:provider_name) { Faker::Company.name }
    let(:start_url) { "https://www.example.com" }
    let(:challenge_url) { "https://www.example.com?token=abc123" }
    let(:expected_notify_id) { "abc123" }

    it "renders the right headers" do
      allow_any_instance_of(Mail::TestMailer).to receive_message_chain(:response, :id) { expected_notify_id }

      actual_notify_id = SchoolMailer.send_partnership_notification_email(
        recipient: recipient,
        provider_name: provider_name,
        start_url: start_url,
        challenge_url: start_url,
      )

      expect(actual_notify_id).to eql expected_notify_id
    end
  end
end
