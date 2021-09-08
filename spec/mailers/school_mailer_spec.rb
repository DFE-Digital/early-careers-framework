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

  describe "#cip_only_invite_email" do
    let(:primary_contact_email) { "contact@example.com" }
    let(:nomination_url) { "https://ecf-dev.london.cloudapps/nominations?token=abc123" }

    let(:cip_only_invite_email) do
      SchoolMailer.cip_only_invite_email(
        recipient: primary_contact_email,
        nomination_url: nomination_url,
        school_name: "Great Ouse Academy",
      ).deliver_now
    end

    it "renders the right headers" do
      expect(cip_only_invite_email.from).to eq(["mail@example.com"])
      expect(cip_only_invite_email.to).to eq([primary_contact_email])
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

  describe "#year2020_add_participants_confirmation" do
    let(:school) { create(:school) }
    let(:ect_one) { create(:user, :early_career_teacher) }
    let(:ect_two) { create(:user, :early_career_teacher) }

    let(:year2020_add_participants_confirmation) do
      SchoolMailer.year2020_add_participants_confirmation(
        school: school,
        participants: [ect_one, ect_two],
      ).deliver_now
    end

    it "renders the right headers" do
      expect(year2020_add_participants_confirmation.to).to eq([school.contact_email])
      expect(year2020_add_participants_confirmation.from).to eq(["mail@example.com"])
    end
  end
end
