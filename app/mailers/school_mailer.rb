# frozen_string_literal: true

class SchoolMailer < ApplicationMailer
  NOMINATION_EMAIL_TEMPLATE = "a7cc4d19-c0cb-4187-a71b-1b1ea029924f"

  def nomination_email(recipient_email, nomination_url, reference)
    template_mail(
      NOMINATION_EMAIL_TEMPLATE,
      to: recipient_email,
      reference: reference,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        nomination_link: nomination_url,
      },
    )
  end
end
