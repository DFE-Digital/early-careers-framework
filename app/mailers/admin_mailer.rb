# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  ADMIN_ACCOUNT_CREATED_TEMPLATE = "3620d073-d2cc-4d65-9a51-e12770cf25d9"

  def account_created_email(admin, url)
    template_mail(
      ADMIN_ACCOUNT_CREATED_TEMPLATE,
      to: admin.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        full_name: admin.full_name,
        sign_in_link: url,
      },
    )
  end
end
