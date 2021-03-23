# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolMailer, type: :mailer do
  describe "#nomination_email" do
    let(:token) { "fedd83c06d5747f1" }
    let(:primary_contact_email) { "contact@example.com" }
    let(:nomination_link) { "https://ecf-dev.london.cloudapps/nominations?token=#{token}" }

    let(:nomination_email) do
      SchoolMailer.nomination_email(primary_contact_email, nomination_link, token)
    end

    it "renders the right headers" do
      expect(nomination_email.from).to eq(["mail@example.com"])
      expect(nomination_email.to).to eq([primary_contact_email])
    end
  end
end
