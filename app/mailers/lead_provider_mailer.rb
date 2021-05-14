# frozen_string_literal: true

class LeadProviderMailer < ApplicationMailer
  WELCOME_EMAIL_TEMPLATE = "07773cdf-9db6-4880-9ac6-ab4454a71d65"

  def welcome_email(user:, lead_provider_name:, start_url:)
    template_mail(
      WELCOME_EMAIL_TEMPLATE,
      to: user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name: user.full_name,
        lead_provider_name: lead_provider_name,
        start_url: start_url,
      },
    )
  end
end
