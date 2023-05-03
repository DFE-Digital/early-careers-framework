# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  let(:email) { "a.user@example.com" }
  let(:user) { create(:user) }

  describe "#sign_in_email" do
    let(:sign_in_email) { UserMailer.with(email:, full_name: user.full_name, url: sign_in_link, token_expiry: "12:00").sign_in_email }

    let(:sign_in_link) do
      Rails.application.routes.url_helpers.users_confirm_sign_in_url(
        login_token: user.login_token, host: Rails.application.config.domain,
      )
    end

    it "renders the right headers and content" do
      expect(sign_in_email.to).to eq([email])
      expect(sign_in_email.from).to eq(["mail@example.com"])
    end
  end
end
