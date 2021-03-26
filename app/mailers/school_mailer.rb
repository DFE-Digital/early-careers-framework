# frozen_string_literal: true

class SchoolMailer < ApplicationMailer
  NOMINATION_EMAIL_TEMPLATE = "a7cc4d19-c0cb-4187-a71b-1b1ea029924f"

  def nomination_email(params)
    template_mail(
      NOMINATION_EMAIL_TEMPLATE,
      to: params[:recipient],
      reference: params[:reference],
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: params[:school_name],
        nomination_link: params[:nomination_url],
      },
    )
  end
end
