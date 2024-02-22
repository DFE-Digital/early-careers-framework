# frozen_string_literal: true

class MentorMailer < ApplicationMailer
  MATERIALS_TEMPLATE = "d5409fd3-bad6-4e98-97d7-69363d2921c8"

  def training_materials
    mentor_email = params[:mentor_email]
    mentor_name = params[:mentor_name]
    school_name = params[:school_name]
    ect_name = params[:ect_name]
    lead_provider_name = params[:lead_provider_name]
    sit_name = params[:sit_name]

    template_mail(
      MATERIALS_TEMPLATE,
      to: mentor_email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        subject: "Access training materials for your new early career teacher",
        mentor_email:,
        mentor_name:,
        school_name:,
        ect_name:,
        lead_provider_name:,
        sit_name:,
      },
    )
  end
end
