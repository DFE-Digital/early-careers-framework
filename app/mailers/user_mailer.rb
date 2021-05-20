# frozen_string_literal: true

class UserMailer < ApplicationMailer
  SIGN_IN_EMAIL_TEMPLATE = "7ab8db5b-9842-4bc3-8dbb-f590a3198d9e"

  def test_email(user:)
    template_mail(
      "aef364b0-8eed-4a7f-89d8-e9af64f09c07",
      to: user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name: user.full_name,
        subject: "Test email",
      }
    )
  end

  def sign_in_email(user:, url:, token_expiry:)
    template_mail(
      SIGN_IN_EMAIL_TEMPLATE,
      to: user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        full_name: user.full_name,
        sign_in_url: url,
        token_expiry: token_expiry,
      },
    )
  end
end
