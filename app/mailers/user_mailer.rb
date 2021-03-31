# frozen_string_literal: true

class UserMailer < ApplicationMailer
  SIGN_IN_EMAIL_TEMPLATE = "7ab8db5b-9842-4bc3-8dbb-f590a3198d9e"
  EMAIL_CONFIRMATION_TEMPLATE = "50059d26-c65d-4e88-831a-8bfb9f4116cd"
  PRIMARY_CONTACT_TEMPLATE = "a7cc4d19-c0cb-4187-a71b-1b1ea029924f"
  TUTOR_NOMINATION_TEMPLATE = "240c5685-5cb0-40a9-9bd4-1a595d991cbc"

  def tutor_nomination_instructions(user, school_name)
    template_mail(
      TUTOR_NOMINATION_TEMPLATE,
      to: user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school_name,
      },
    )
  end

  def sign_in_email(user, url)
    template_mail(
      SIGN_IN_EMAIL_TEMPLATE,
      to: user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        full_name: user.full_name,
        sign_in_url: url,
      },
    )
  end

  def confirmation_instructions(user, token, _options = {})
    confirmation_url = Rails.application.routes.url_helpers.user_confirmation_url(
      confirmation_token: token,
      host: Rails.application.config.domain,
    )

    template_mail(
      EMAIL_CONFIRMATION_TEMPLATE,
      to: user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        full_name: user.full_name,
        confirmation_url: confirmation_url,
      },
    )
  end

  def primary_contact_notification(coordinator, school)
    template_mail(
      PRIMARY_CONTACT_TEMPLATE,
      to: school.primary_contact_email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        coordinator_full_name: coordinator.full_name,
        coordinator_email_address: coordinator.email,
      },
    )
  end
end
