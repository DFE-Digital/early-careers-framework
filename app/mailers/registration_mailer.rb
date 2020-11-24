class RegistrationMailer < ApplicationMailer
  REGISTRATION_EMAIL_TEMPLATE = "07cd5baf-66c9-49b1-bc3c-ed8b5434706a".freeze

  def send_registration_email(email_address, user_name, confirm_email_url)
    template_mail(
      REGISTRATION_EMAIL_TEMPLATE,
      to: email_address,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name: user_name,
        confirm_email_url: confirm_email_url,
      },
    )
  end
end
