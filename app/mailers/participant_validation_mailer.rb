# frozen_string_literal: true

class ParticipantValidationMailer < ApplicationMailer
  INDUCTION_COORDINATOR_WE_ASKED_YOUR_ECTS_AND_MENTORS_TEMPLATE = "d560fb2e-243d-48b1-bf61-c7e111f56858"

  ECTS_TO_ADD_VALIDATIN_INFO_TEMPLATE = "50ee41e5-06b9-41cf-9afd-d5bc4db356c4"
  MENTORS_TO_ADD_VALIDATION_EMAIL_TEMPLATE = "e0198213-c09d-41aa-8197-b167e495e49d"
  INDUCTION_COORDINATORS_WHO_ARE_MENTORS_TO_ADD_VALIDATION_EMAIL_TEMPLATE = "7e7d3fdb-41f5-4e04-a4ae-acf92e8fefe6"

  STATUTORY_GUIDANCE_LINK = "https://www.gov.uk/government/publications/induction-for-early-career-teachers-england"

  def ects_to_add_validation_information_email(recipient:, school_name:, start_url:)
    template_mail(
      ECTS_TO_ADD_VALIDATIN_INFO_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school_name,
        participant_start: start_url,
      },
    )
  end

  def mentors_to_add_validation_information_email(recipient:, school_name:, start_url:)
    template_mail(
      MENTORS_TO_ADD_VALIDATION_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school_name,
        participant_start: start_url,
      },
    )
  end

  def induction_coordinators_who_are_mentors_to_add_validation_information_email(recipient:, school_name:, start_url:)
    template_mail(
      INDUCTION_COORDINATORS_WHO_ARE_MENTORS_TO_ADD_VALIDATION_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school_name,
        participant_start: start_url,
      },
    )
  end

  def induction_coordinators_we_asked_ects_and_mentors_for_information_email(recipient:, sign_in:, school_name:)
    template_mail(
      INDUCTION_COORDINATOR_WE_ASKED_YOUR_ECTS_AND_MENTORS_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        sign_in: sign_in,
        school_name: school_name,
      },
    )
  end
end
