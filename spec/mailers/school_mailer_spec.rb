# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolMailer, type: :mailer do
  describe "#nomination_email" do
    let(:primary_contact_email) { "contact@example.com" }
    let(:nomination_url) { "https://ecf-dev.london.cloudapps/nominations?token=abc123" }

    let(:nomination_email) do
      SchoolMailer.nomination_email(
        recipient: primary_contact_email,
        nomination_url: nomination_url,
        school_name: "Great Ouse Academy",
        expiry_date: "1/1/2000",
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

  describe "#coordinator_partnership_notification_email" do
    let(:recipient) { Faker::Internet.email }
    let(:name) { Faker::Name.name }
    let(:provider_name) { Faker::Company.name }
    let(:school_name) { Faker::Company.name }
    let(:sign_in_url) { "https://www.example.com/sign-in" }
    let(:challenge_url) { "https://www.example.com?token=abc123" }
    let(:challenge_deadline) { "1/1/1970" }

    let(:partnership_notification_email) do
      SchoolMailer.coordinator_partnership_notification_email(
        recipient: recipient,
        name: name,
        lead_provider_name: provider_name,
        delivery_partner_name: provider_name,
        school_name: school_name,
        sign_in_url: sign_in_url,
        challenge_url: challenge_url,
        challenge_deadline: challenge_deadline,
      )
    end

    it "renders the right headers" do
      expect(partnership_notification_email.from).to eq(["mail@example.com"])
      expect(partnership_notification_email.to).to eq([recipient])
    end
  end

  describe "#school_partnership_notification_email" do
    let(:recipient) { Faker::Internet.email }
    let(:provider_name) { Faker::Company.name }
    let(:school_name) { Faker::Company.name }
    let(:nominate_url) { "https://www.example.com?token=def456" }
    let(:challenge_url) { "https://www.example.com?token=abc123" }
    let(:challenge_deadline) { "1/1/1970" }

    let(:partnership_notification_email) do
      SchoolMailer.school_partnership_notification_email(
        recipient: recipient,
        lead_provider_name: provider_name,
        delivery_partner_name: provider_name,
        school_name: school_name,
        nominate_url: nominate_url,
        challenge_url: challenge_url,
        challenge_deadline: challenge_deadline,
      )
    end

    it "renders the right headers" do
      expect(partnership_notification_email.from).to eq(["mail@example.com"])
      expect(partnership_notification_email.to).to eq([recipient])
    end
  end

  describe "#participant_validation_ect_email" do
    let(:recipient) { Faker::Internet.email }
    let(:school_name) { Faker::Company.name }
    let(:start_url) { "https://www.example.com/participants/start-registration" }
    let(:research_url) { "https://www.example.com/pages/user-research" }

    let(:participant_validation_ect_email) do
      SchoolMailer.participant_validation_ect_email(
        recipient: recipient,
        school_name: school_name,
        start_url: start_url,
        user_research_url: research_url,
      )
    end

    it "renders the right headers" do
      expect(participant_validation_ect_email.from).to match_array ["mail@example.com"]
      expect(participant_validation_ect_email.to).to match_array [recipient]
    end
  end

  describe "#participant_validation_fip_mentor_email" do
    let(:recipient) { Faker::Internet.email }
    let(:school_name) { Faker::Company.name }
    let(:start_url) { "https://www.example.com/participants/start-registration" }
    let(:research_url) { "https://www.example.com/pages/user-research" }

    let(:participant_validation_fip_mentor_email) do
      SchoolMailer.participant_validation_fip_mentor_email(
        recipient: recipient,
        school_name: school_name,
        start_url: start_url,
        user_research_url: research_url,
      )
    end

    it "renders the right headers" do
      expect(participant_validation_fip_mentor_email.from).to match_array ["mail@example.com"]
      expect(participant_validation_fip_mentor_email.to).to match_array [recipient]
    end
  end
end
