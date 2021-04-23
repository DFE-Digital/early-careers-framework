# frozen_string_literal: true

require "rails_helper"

RSpec.describe NominationEmail, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:school) }
    it { is_expected.to belong_to(:partnership_notification_email).optional(true) }
  end

  describe ".create_nomination_email" do
    let(:school) { create(:school) }
    let(:email) { Faker::Internet.email }
    let(:sent_at) { Time.utc(2020, 3, 4) }

    it "creates a record with a token" do
      expect {
        NominationEmail.create_nomination_email(
          sent_at: sent_at,
          sent_to: email,
          school: school,
        )
      }.to change { NominationEmail.count }.by 1

      nomination_email = NominationEmail.first
      expect(nomination_email.sent_at).to eql sent_at
      expect(nomination_email.sent_to).to eql email
      expect(nomination_email.school).to eql school
      expect(nomination_email.token.length).to eql 32
    end
  end

  describe "expired email" do
    let(:expired_nomination_email) { create(:nomination_email, :expired_nomination_email) }

    it "shows as expired once it goes beyond expiration date" do
      expect(expired_nomination_email.expired?).to eq true
    end
  end

  describe "nearly expired email" do
    let!(:nearly_expired_nomination_email) { create(:nomination_email, :nearly_expired_nomination_email) }

    it "is not expired" do
      expect(nearly_expired_nomination_email.expired?).to eq false
    end

    it "expires when time passes" do
      travel_to 2.days.from_now

      expect(nearly_expired_nomination_email.expired?).to eq true
    end
  end

  describe "not expired email" do
    let(:new_nomination_email) { create(:nomination_email) }

    it "is not expired" do
      expect(new_nomination_email.expired?).to eq false
    end

    it "is sent within the last hour" do
      expect(new_nomination_email.sent_within_last?(1.hour)).to eq true
    end
  end
end
