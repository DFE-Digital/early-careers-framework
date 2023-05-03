# frozen_string_literal: true

class ParticipantValidationMailer < ApplicationMailer
  INDUCTION_COORDINATOR_WE_ASKED_YOUR_ECTS_AND_MENTORS_TEMPLATE = "d560fb2e-243d-48b1-bf61-c7e111f56858"

  ECTS_TO_ADD_VALIDATIN_INFO_TEMPLATE = "50ee41e5-06b9-41cf-9afd-d5bc4db356c4"
  MENTORS_TO_ADD_VALIDATION_EMAIL_TEMPLATE = "e0198213-c09d-41aa-8197-b167e495e49d"
  INDUCTION_COORDINATORS_WHO_ARE_MENTORS_TO_ADD_VALIDATION_EMAIL_TEMPLATE = "7e7d3fdb-41f5-4e04-a4ae-acf92e8fefe6"
  INDUCTION_COORDINATOR_PARTICIPANT_EMAIL_BOUNCED_TEMPLATE = "d46b1f7b-4d80-4a91-91c7-f1cfac3bdbe1"
  FIP_PARTICIPANT_VALIDATION_DEADLINE_REMINDER_TEMPLATE = "0bc719e5-760a-412c-b5ec-080f47b3d9db"

  STATUTORY_GUIDANCE_LINK = "https://www.gov.uk/government/publications/induction-for-early-career-teachers-england"

  def ects_to_add_validation_information_email
    template_mail(
      ECTS_TO_ADD_VALIDATIN_INFO_TEMPLATE,
      to: params[:recipient],
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: params[:school_name],
        participant_start: params[:start_url],
      },
    )
  end

  def mentors_to_add_validation_information_email
    template_mail(
      MENTORS_TO_ADD_VALIDATION_EMAIL_TEMPLATE,
      to: params[:recipient],
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: params[:school_name],
        participant_start: params[:start_url],
      },
    )
  end

  def induction_coordinators_who_are_mentors_to_add_validation_information_email
    template_mail(
      INDUCTION_COORDINATORS_WHO_ARE_MENTORS_TO_ADD_VALIDATION_EMAIL_TEMPLATE,
      to: params[:recipient],
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: params[:school_name],
        participant_start: params[:start_url],
      },
    )
  end

  def induction_coordinators_we_asked_ects_and_mentors_for_information_email
    template_mail(
      INDUCTION_COORDINATOR_WE_ASKED_YOUR_ECTS_AND_MENTORS_TEMPLATE,
      to: params[:recipient],
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        sign_in: params[:sign_in],
        participant_start: params[:start_url],
      },
    ).tag(:sit_unvalidated_participants_reminder).associate_with(params[:induction_coordinator_profile], as: :induction_coordinator_profile)
  end

  def induction_coordinator_participant_email_bounced_email
    participant_profile = params[:participant_profile]

    template_mail(
      INDUCTION_COORDINATOR_PARTICIPANT_EMAIL_BOUNCED_TEMPLATE,
      to: params[:recipient],
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        sign_in: params[:sign_in_url],
        participant_name: participant_profile.user.full_name,
      },
    ).tag(:sit_participant_email_bounced).associate_with(participant_profile, as: :participant_profile)
  end

  def fip_participant_validation_deadline_reminder_email
    participant_profile = params[:participant_profile]

    template_mail(
      FIP_PARTICIPANT_VALIDATION_DEADLINE_REMINDER_TEMPLATE,
      to: participant_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name: participant_profile.user.full_name,
        school_name: participant_profile.school.name,
        participant_start: params[:participant_start_url],
      },
    ).tag(:fip_participant_validation_deadline).associate_with(participant_profile, as: :participant_profile)
  end
end
