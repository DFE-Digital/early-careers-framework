# frozen_string_literal: true

class ParticipantValidationMailer < ApplicationMailer
  CIP_AND_FIP_ECT_TEMPLATE = "50ee41e5-06b9-41cf-9afd-d5bc4db356c4"
  CIP_AND_FIP_ECT_UR_TEMPLATE = "b73fe1d1-94ac-4e77-ab37-71738c2474dd"
  FIP_MENTOR_TEMPLATE = "691eb49b-f23f-49dd-b799-f8efdd5e010f"
  FIP_MENTOR_UR_TEMPLATE = "06ad385b-9a76-4f5c-941a-c5d8cf5f72c7"
  CIP_MENTOR_TEMPLATE = "1be6cac7-9fa5-482a-b924-753dfe4a3a0c"
  ENGAGE_BETA_MENTOR_TEMPLATE = "99dacb2d-2255-4aa8-9076-46fa6093f1e5"
  INDUCTION_COORDINATOR_NOTIFICATION_TEMPLATE = "d560fb2e-243d-48b1-bf61-c7e111f56858"
  INDUCTION_COORDINATOR_NOTIFICATION_UR_TEMPLATE = "afb54050-7ebd-43af-ad83-7fa6795d1523"
  INDUCTION_COORDINATOR_CHECK_ECT_AND_MENTOR_TEMPLATE = "127f972e-3b78-4780-9933-c9bb889af663"
  INDUCTION_COORDINATOR_WE_ASKED_YOUR_ECTS_AND_MENTORS_TEMPLATE = "d560fb2e-243d-48b1-bf61-c7e111f56858"
  COORDINATOR_AND_MENTOR_UR_TEMPLATE = "5e53ac12-65e2-4196-a894-2b23bf07f334"
  COORDINATOR_AND_MENTOR_TEMPLATE = "7e7d3fdb-41f5-4e04-a4ae-acf92e8fefe6"

  ECTS_TO_ADD_VALIDATIN_INFO_TEMPLATE = "50ee41e5-06b9-41cf-9afd-d5bc4db356c4"
  MENTORS_TO_ADD_VALIDATION_EMAIL_TEMPLATE = "e0198213-c09d-41aa-8197-b167e495e49d"
  INDUCTION_COORDINATORS_WHO_ARE_MENTORS_TO_ADD_VALIDATION_EMAIL_TEMPLATE = "7e7d3fdb-41f5-4e04-a4ae-acf92e8fefe6"

  STATUTORY_GUIDANCE_LINK = "https://www.gov.uk/government/publications/induction-for-early-career-teachers-england"

  def ect_email(recipient:, school_name:, start_url:)
    template_mail(
      CIP_AND_FIP_ECT_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school_name,
        participant_start: start_url,
      },
    )
  end

  def ect_ur_email(recipient:, school_name:, start_url:, user_research_url:)
    template_mail(
      CIP_AND_FIP_ECT_UR_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school_name,
        participant_start: start_url,
        ur_sign_up_url: user_research_url,
      },
    )
  end

  def fip_mentor_email(recipient:, school_name:, start_url:)
    template_mail(
      FIP_MENTOR_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school_name,
        participant_start: start_url,
      },
    )
  end

  def fip_mentor_ur_email(recipient:, school_name:, start_url:, user_research_url:)
    template_mail(
      FIP_MENTOR_UR_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school_name,
        participant_start: start_url,
        ur_sign_up_url: user_research_url,
      },
    )
  end

  def cip_mentor_email(recipient:, school_name:, start_url:)
    template_mail(
      CIP_MENTOR_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school_name,
        participant_start: start_url,
      },
    )
  end

  def engage_beta_mentor_email(recipient:, school_name:, start_url:)
    template_mail(
      ENGAGE_BETA_MENTOR_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school_name,
        participant_start: start_url,
      },
    )
  end

  def induction_coordinator_email(recipient:, school_name:, start_url:)
    template_mail(
      INDUCTION_COORDINATOR_NOTIFICATION_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school_name,
        start_url: start_url,
      },
    )
  end

  def induction_coordinator_check_ect_and_mentor_email(recipient:, sign_in:, step_by_step:, resend_email:)
    template_mail(
      INDUCTION_COORDINATOR_CHECK_ECT_AND_MENTOR_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        statutory_guidance: STATUTORY_GUIDANCE_LINK,
        sign_in: sign_in,
        step_by_step: step_by_step,
        resend_email: resend_email,
      },
    )
  end

  def induction_coordinator_ur_email(recipient:, school_name:, start_url:)
    template_mail(
      INDUCTION_COORDINATOR_NOTIFICATION_UR_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school_name,
        start_url: start_url,
      },
    )
  end

  def coordinator_and_mentor_email(recipient:, school_name:, start_url:)
    template_mail(
      COORDINATOR_AND_MENTOR_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school_name,
        participant_start: start_url,
      },
    )
  end

  def coordinator_and_mentor_ur_email(recipient:, school_name:, start_url:, user_research_url:)
    template_mail(
      COORDINATOR_AND_MENTOR_UR_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school_name,
        participant_start: start_url,
        ur_sign_up_url: user_research_url,
      },
    )
  end

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
