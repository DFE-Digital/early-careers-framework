# frozen_string_literal: true

require "rails_helper"

RSpec.describe AppropriateBodyProfileMailer, type: :mailer do
  let(:appropriate_body_profile) { create(:appropriate_body_profile) }

  describe "#welcome" do
    let(:welcome_email) do
      AppropriateBodyProfileMailer.welcome(
        appropriate_body_profile,
      ).deliver_now
    end

    it "renders the right headers" do
      expect(welcome_email.from).to eq(["mail@example.com"])
      expect(welcome_email.to).to eq([appropriate_body_profile.user.email])
    end
  end
end
