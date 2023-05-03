# frozen_string_literal: true

class DeliveryPartnerProfileMailer < ApplicationMailer
  WELCOME_TEMPLATE_ID = "d477ea16-169b-415e-a87e-1fba314b77e8"

  def welcome(delivery_partner_profile)
    template_mail(
      WELCOME_TEMPLATE_ID,
      to: delivery_partner_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name: delivery_partner_profile.user.full_name,
        delivery_partners_url: start_delivery_partners_url(**UTMService.email(:delivery_partner_profile_welcome)),
      },
    ).tag(:delivery_partner_profile_welcome).associate_with(delivery_partner_profile, as: :delivery_partner_profile)
  end
end
