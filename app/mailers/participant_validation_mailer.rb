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
  # TODO: add real uuid, this is a dummy one
  INDUCTION_COORDINATOR_VALIDATION_NOTIFICATION_TEMPLATE = "4eb4455d-6b33-4af3-aa40-43b47bfc5501"
  COORDINATOR_AND_MENTOR_UR_TEMPLATE = "5e53ac12-65e2-4196-a894-2b23bf07f334"
  COORDINATOR_AND_MENTOR_TEMPLATE = "7e7d3fdb-41f5-4e04-a4ae-acf92e8fefe6"

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

  def induction_coordinator_validation_notification_email(recipient:, school_name:, start_url:)
    template_mail(
      INDUCTION_COORDINATOR_VALIDATION_NOTIFICATION_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school_name,
        start_url: start_url,
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
end
