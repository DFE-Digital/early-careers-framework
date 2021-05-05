# frozen_string_literal: true

require "rails_helper"

RSpec.describe LeadProviderMailer, type: :mailer do
  describe "#welcome_email_confirmation" do
    let(:lead_provider) { build(:lead_provider) }
    let(:user) { create(:user, :lead_provider) }
    let(:start_url) { "https://ecf-dev.london.cloudapps" }

    let(:nomination_confirmation_email) do
      LeadProviderMailer.welcome_email(
        user: user,
        lead_provider_name: lead_provider.name,
        start_url: start_url,
      ).deliver_now
    end

    it "renders the right headers" do
      expect(nomination_confirmation_email.to).to eq([user.email])
      expect(nomination_confirmation_email.from).to eq(["mail@example.com"])
    end
  end
end
