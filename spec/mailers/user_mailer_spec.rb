require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  subject(:mail) { UserMailer.sign_in_email(user, sign_in_link) }
  let(:user) { create(:user) }

  let(:sign_in_link) do
    Rails.application.routes.url_helpers.email_confirmation_url(
      login_token: user.login_token, host: Rails.application.config.domain,
    )
  end

  describe "#sign_in_email" do
    it "renders the right headers and content" do
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["mail@example.com"])
    end
  end
end
