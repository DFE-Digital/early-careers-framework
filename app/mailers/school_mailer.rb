# frozen_string_literal: true

class SchoolMailer < ApplicationMailer
  NOMINATION_EMAIL_TEMPLATE = "a7cc4d19-c0cb-4187-a71b-1b1ea029924f"
  NOMINATION_CONFIRMATION_EMAIL_TEMPLATE = "240c5685-5cb0-40a9-9bd4-1a595d991cbc"

  def nomination_email(recipient:, reference:, school_name:, nomination_url:)
    template_mail(
      NOMINATION_EMAIL_TEMPLATE,
      to: recipient,
      reference: reference,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school_name,
        nomination_link: nomination_url,
      },
    )
  end

  def nomination_confirmation_email(tutor:, school:, sign_in_url:)
    template_mail(
      NOMINATION_CONFIRMATION_EMAIL_TEMPLATE,
      to: tutor.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school.name,
        sign_in_url: sign_in_url,
      },
    )
  end
end
