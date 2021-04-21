# frozen_string_literal: true

require "rails_helper"

RSpec.describe NominationEmail, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:school) }
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
