# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeliveryPartnerProfileMailer, type: :mailer do
  let(:delivery_partner_profile) { create(:delivery_partner_profile) }

  describe "#welcome" do
    let(:welcome_email) do
      DeliveryPartnerProfileMailer.welcome(
        delivery_partner_profile,
      ).deliver_now
    end

    it "renders the right headers" do
      expect(welcome_email.from).to eq(["mail@example.com"])
      expect(welcome_email.to).to eq([delivery_partner_profile.user.email])
    end
  end
end
