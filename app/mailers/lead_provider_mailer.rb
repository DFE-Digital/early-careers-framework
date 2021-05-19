# frozen_string_literal: true

class LeadProviderMailer < ApplicationMailer
  WELCOME_EMAIL_TEMPLATE = "07773cdf-9db6-4880-9ac6-ab4454a71d65"
  PARTNERSHIP_CHALLENGED_TEMPLATE_ID = "01c1ab30-1a45-4ce7-b994-e4df8334f23b"

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

  def partnership_challenged_email(partnership:, user:)
    # TODO: We should not be going back to the form to fetch that!
    reason = ChallengePartnershipForm.new.challenge_reason_options
      .find { |option| option.id == partnership.challenge_reason }
      .name

    template_mail(
      PARTNERSHIP_CHALLENGED_TEMPLATE_ID,
      to: user.email,
      rails_mailer: mailer_name,
      rails_mailer_template: action_name,
      personalisation: {
        name: user.full_name,
        school_name: partnership.school.name,
        school_urn: partnership.school.urn,
        delivery_partner_name: partnership.delivery_partner.name,
        reason: reason,
      },
    )
  end
end
