# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  let(:user) { create(:user) }

  describe "#sign_in_email" do
    let(:sign_in_email) { UserMailer.sign_in_email(user, sign_in_link) }

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

  describe "#confirmation_instructions" do
    let(:confirmation_email) do
      UserMailer.confirmation_instructions(user, confirmation_link)
    end

    let(:confirmation_link) do
      Rails.application.routes.url_helpers.user_confirmation_url(
        confirmation_token: "scTgxc178f", host: Rails.application.config.domain,
      )
    end

    it "renders the right headers" do
      expect(confirmation_email.to).to eq([user.email])
      expect(confirmation_email.from).to eq(["mail@example.com"])
    end
  end

  describe "#primary_contact_notification" do
    let(:school) { create(:school) }
    let(:coordinator) { create(:user) }

    let(:notification_email) do
      UserMailer.primary_contact_notification(coordinator, school)
    end

    it "renders the right headers" do
      expect(notification_email.from).to eq(["mail@example.com"])
      expect(notification_email.to).to eq([school.primary_contact_email])
    end
  end
end
