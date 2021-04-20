# frozen_string_literal: true

require "rails_helper"

RSpec.describe PartnershipNotificationEmail, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:partnership) }
    it { is_expected.to have_one(:nomination_email) }
    it { is_expected.to delegate_method(:school).to(:partnership) }
    it { is_expected.to delegate_method(:lead_provider).to(:partnership) }
    it { is_expected.to delegate_method(:delivery_partner).to(:partnership).allow_nil }
    it { is_expected.to delegate_method(:cohort).to(:partnership) }
  end

  describe "#token_expired?" do
    it "returns true when the token is more than 14 days old" do
      email = create(:partnership_notification_email)

      travel 15.days

      expect(email.token_expired?).to eq true
    end

    it "returns false when the token is less than 14 days old" do
      email = create(:partnership_notification_email)

      travel 13.days

      expect(email.token_expired?).to eq false
    end
  end
end
