# frozen_string_literal: true

class AppropriateBodyProfileMailer < ApplicationMailer
  WELCOME_TEMPLATE_ID = "0835a51f-dd7e-4a5e-b6e2-0b143de02eeb"

  def welcome(appropriate_body_profile)
    template_mail(
      WELCOME_TEMPLATE_ID,
      to: appropriate_body_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name: appropriate_body_profile.user.full_name,
        appropriate_bodies_url: start_appropriate_bodies_url(**UTMService.email(:appropriate_body_profile_welcome)),
      },
    ).tag(:appropriate_body_profile_welcome).associate_with(appropriate_body_profile, as: :appropriate_body_profile)
  end
end
