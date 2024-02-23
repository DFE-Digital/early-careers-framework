# frozen_string_literal: true

class MentorMailer < ApplicationMailer
  MATERIALS_TEMPLATE = "d5409fd3-bad6-4e98-97d7-69363d2921c8"

  def training_materials
    mentor_profile = params[:mentor_profile]
    mentor_email = mentor_profile.user.email
    mentor_name = mentor_profile.user.full_name
    ect_name = params[:ect_name]
    cip_materials_name = params[:cip_materials_name]
    sit_name = params[:sit_name]

    template_mail(
      MATERIALS_TEMPLATE,
      to: mentor_email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        subject: "Access training materials for your new early career teacher",
        mentor_name:,
        ect_name:,
        cip_materials_name:,
        sit_name:,
      },
    ).tag(:send_cip_materials_to_mentor).associate_with(mentor_profile, as: :mentor_profile)
  end
end
