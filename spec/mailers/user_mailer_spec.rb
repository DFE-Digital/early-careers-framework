# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  let(:user) { create(:user) }

  describe "#sign_in_email" do
    let(:sign_in_email) { UserMailer.sign_in_email(user: user, url: sign_in_link, token_expiry: "12:00") }

    let(:sign_in_link) do
      Rails.application.routes.url_helpers.users_confirm_sign_in_url(
        login_token: user.login_token, host: Rails.application.config.domain,
      )
    end

    it "renders the right headers and content" do
      expect(sign_in_email.to).to eq([user.email])
      expect(sign_in_email.from).to eq(["mail@example.com"])
    end
  end
end
