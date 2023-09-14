# frozen_string_literal: true

class UserMailer < ApplicationMailer
  SIGN_IN_EMAIL_TEMPLATE = "7ab8db5b-9842-4bc3-8dbb-f590a3198d9e"
  ACCESS_INFO_EMAIL_TEMPLATE = "fa5a9bca-ac57-435d-b450-201ca209379b"

  def test_email
    user = params[:user]

    template_mail(
      "aef364b0-8eed-4a7f-89d8-e9af64f09c07",
      to: user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name: user.full_name,
        subject: "Test email",
      },
    ).tag(:test_email)
  end

  def sign_in_email
    template_mail(
      SIGN_IN_EMAIL_TEMPLATE,
      to: params[:email],
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        full_name: params[:full_name],
        sign_in: params[:url],
        token_expiry: params[:token_expiry],
        subject: "Link to sign in",
      },
    ).tag(:sign_in)
  end

  def access_info_email
    recipient = params[:recipient]

    template_mail(
      ACCESS_INFO_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        service_url: root_url,
        sign_in: new_user_session_url,
        request_access: resend_email_request_nomination_invite_url,
      },
    ).tag(:access_info_email)
  end
end
