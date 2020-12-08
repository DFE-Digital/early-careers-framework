require 'byebug'
class UserMailer < ApplicationMailer
  SIGN_IN_EMAIL_TEMPLATE = "7ab8db5b-9842-4bc3-8dbb-f590a3198d9e".freeze
  EMAIL_CONFIRMATION_TEMPLATE = "50059d26-c65d-4e88-831a-8bfb9f4116cd".freeze

  def sign_in_email(user, url)
    template_mail(
      SIGN_IN_EMAIL_TEMPLATE,
      to: user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        first_name: user.first_name.capitalize,
        sign_in_url: url,
      },
    )
  end

  def confirmation_instructions(user, token, options={})
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
        first_name: user.first_name.capitalize,
        confirmation_url: confirmation_url,
      },
    )
  end
end
