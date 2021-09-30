# frozen_string_literal: true

class SchoolMailer < ApplicationMailer
  NOMINATION_EMAIL_TEMPLATE = "a7cc4d19-c0cb-4187-a71b-1b1ea029924f"
  NOMINATION_CONFIRMATION_EMAIL_TEMPLATE = "240c5685-5cb0-40a9-9bd4-1a595d991cbc"
  SCHOOL_PARTNERSHIP_NOTIFICATION_EMAIL_TEMPLATE = "99991fd9-fb41-48cf-846d-98a1fee7762a"
  COORDINATOR_PARTNERSHIP_NOTIFICATION_EMAIL_TEMPLATE = "076e8486-cbcc-44ee-8a6e-d2a721ee1460"
  MINISTERIAL_LETTER_EMAIL_TEMPLATE = "f1310917-aa50-4789-b8c2-8cc5e9b91485"
  BETA_INVITE_EMAIL_TEMPLATE = "0ae827de-3caa-4a93-b464-c434cbbd02c0"
  MAT_INVITE_EMAIL_TEMPLATE = "f856f50e-6f49-441e-8018-f8303367eb5c"
  CIP_ONLY_INVITE_EMAIL_TEMPLATE = "ee814b67-52e3-409d-8350-5140e6741124"
  FEDERATION_INVITE_EMAIL_TEMPLATE = "9269c50d-b579-425b-b55b-4c93f67074d4"
  SECTION_41_INVITE_EMAIL_TEMPLATE = "a4ba1de4-e401-47f4-ac77-60c1da17a0e5"
  COORDINATOR_SIGN_IN_CHASER_EMAIL_TEMPLATE = "b5c318a4-2171-4ded-809a-af72dd87e7a7"
  COORDINATOR_REMINDER_TO_CHOOSE_ROUTE_EMAIL_TEMPLATE = "c939c27a-9951-4ac3-817d-56b7bf343fb4"
  COORDINATOR_REMINDER_TO_CHOOSE_PROVIDER_EMAIL_TEMPLATE = "11cdb6d8-8a59-4618-ba35-0ebd7e47180c"
  COORDINATOR_REMINDER_TO_CHOOSE_MATERIALS_EMAIL_TEMPLATE = "43baf25c-6a46-437b-9f30-77c57d68a59e"
  ADD_PARTICIPANTS_EMAIL_TEMPLATE = "721787d0-74bc-42a0-a064-ee0c1cb58edb"
  BASIC_TEMPLATE = "b1ab542e-a8d5-4fdf-a7aa-f0ce49b98262"
  NQT_PLUS_ONE_SITLESS_EMAIL_TEMPLATE = "c10392e4-9d75-402d-a7fd-47df16fa6082"
  NQT_PLUS_ONE_SIT_EMAIL_TEMPLATE = "9e01b5ac-a94c-4c71-a38d-6502d7c4c2e7"
  PARTNERED_SCHOOL_INVITE_SIT_EMAIL_TEMPLATE = "8cac177e-b094-4a00-9179-94fadde8ced0"

  def remind_induction_coordinator_to_setup_cohort_email(recipient:, school_name:, campaign: nil)
    campaign_tracking = campaign ? UTMService.email(campaign, campaign) : {}

    template_mail(
      "14aabb56-1d6e-419f-8144-58a0439c61a6",
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        subject: "You need to set up your ECT training programme",
        school_name: school_name,
        sign_in: new_user_session_url(**campaign_tracking),
        step_by_step: step_by_step_url(**campaign_tracking),
      },
    )
  end

  def nomination_email(recipient:, school_name:, nomination_url:, expiry_date:)
    template_mail(
      NOMINATION_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school_name,
        nomination_link: nomination_url,
        expiry_date: expiry_date,
        subject: "Important: NQT induction changes",
      },
    )
  end

  def nomination_confirmation_email(user:, school:, start_url:, step_by_step_url:)
    template_mail(
      NOMINATION_CONFIRMATION_EMAIL_TEMPLATE,
      to: user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school.name,
        start_url: start_url,
        subject: "Sign in to manage induction",
        step_by_step: step_by_step_url,
      },
    )
  end

  def school_partnership_notification_email(
    recipient:,
    lead_provider_name:,
    delivery_partner_name:,
    school_name:,
    nominate_url:,
    challenge_url:,
    challenge_deadline:
  )
    template_mail(
      SCHOOL_PARTNERSHIP_NOTIFICATION_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        lead_provider_name: lead_provider_name,
        delivery_partner_name: delivery_partner_name,
        school_name: school_name,
        nominate_url: nominate_url,
        challenge_url: challenge_url,
        challenge_deadline: challenge_deadline,
        subject: "FAO: NQT coordinator. Training provider confirmed.",
      },
    )
  end

  def partnered_school_invite_sit_email(
    recipient:,
    lead_provider_name:,
    delivery_partner_name:,
    nominate_url:,
    challenge_url:
  )

    template_mail(
      PARTNERED_SCHOOL_INVITE_SIT_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        lead_provider_name: lead_provider_name,
        delivery_partner_name: delivery_partner_name,
        nominate_url: nominate_url,
        challenge_url: challenge_url,
      },
    )
  end

  def coordinator_partnership_notification_email(
    recipient:,
    name:,
    lead_provider_name:,
    delivery_partner_name:,
    school_name:,
    sign_in_url:,
    challenge_url:,
    challenge_deadline:
  )
    template_mail(
      COORDINATOR_PARTNERSHIP_NOTIFICATION_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name: name,
        lead_provider_name: lead_provider_name,
        delivery_partner_name: delivery_partner_name,
        school_name: school_name,
        sign_in_url: sign_in_url,
        challenge_url: challenge_url,
        challenge_deadline: challenge_deadline,
        subject: "Training provider confirmed: add your ECTs and mentors",
      },
    )
  end

  def ministerial_letter_email(recipient:)
    template_mail(
      MINISTERIAL_LETTER_EMAIL_TEMPLATE,
      to: recipient,
      reply_to_id: "84c368c3-4ff0-4b81-93d3-bc75291f4153",
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        letter_url: Rails.application.routes.url_helpers.ministerial_letter_url(host: Rails.application.config.domain),
        leaflet_url: Rails.application.routes.url_helpers.ecf_leaflet_url(host: Rails.application.config.domain),
      },
    )
  end

  def beta_invite_email(recipient:, name:, school_name:, start_url:)
    template_mail(
      BETA_INVITE_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name: name,
        school_name: school_name,
        start_url: start_url,
      },
    )
  end

  def mat_invite_email(recipient:, school_name:, nomination_url:)
    template_mail(
      MAT_INVITE_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school_name,
        nomination_url: nomination_url,
      },
    )
  end

  def federation_invite_email(recipient:, school_name:, nomination_url:)
    template_mail(
      FEDERATION_INVITE_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school_name,
        nomination_url: nomination_url,
      },
    )
  end

  def cip_only_invite_email(recipient:, school_name:, nomination_url:)
    template_mail(
      CIP_ONLY_INVITE_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school_name,
        nomination_link: nomination_url,
      },
    )
  end

  def section_41_invite_email(recipient:, school_name:, nomination_url:)
    template_mail(
      SECTION_41_INVITE_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school_name,
        nomination_link: nomination_url,
      },
    )
  end

  def induction_coordinator_sign_in_chaser_email(recipient:, name:, school_name:, sign_in_url:)
    template_mail(
      COORDINATOR_SIGN_IN_CHASER_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name: name,
        school_name: school_name,
        sign_in_url: sign_in_url,
      },
    )
  end

  def induction_coordinator_reminder_to_choose_route_email(recipient:, name:, school_name:, sign_in_url:)
    template_mail(
      COORDINATOR_REMINDER_TO_CHOOSE_ROUTE_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name: name,
        school_name: school_name,
        sign_in_url: sign_in_url,
      },
    )
  end

  def induction_coordinator_reminder_to_choose_provider_email(recipient:)
    template_mail(
      COORDINATOR_REMINDER_TO_CHOOSE_PROVIDER_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {},
    )
  end

  def induction_coordinator_reminder_to_choose_materials_email(recipient:, name:, school_name:, sign_in_url:)
    template_mail(
      COORDINATOR_REMINDER_TO_CHOOSE_MATERIALS_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name: name,
        school_name: school_name,
        sign_in_url: sign_in_url,
      },
    )
  end

  def induction_coordinator_add_participants_email(recipient:, name:, sign_in_url:)
    template_mail(
      ADD_PARTICIPANTS_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name: name,
        sign_in_url: sign_in_url,
      },
    )
  end

  def year2020_add_participants_confirmation(school:, participants:)
    @school = school
    @participants = participants

    view_mail(
      BASIC_TEMPLATE,
      to: school.contact_email,
      subject: "2020 to 2021 NQTs cohort: support materials confirmation",
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      template_name: :year2020_ects_added_confirmation,
    )
  end

  def nqt_plus_one_sitless_invite(recipient:, start_url:)
    template_mail(
      NQT_PLUS_ONE_SITLESS_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        start_url: start_url,
      },
    )
  end

  def nqt_plus_one_sit_invite(recipient:, start_url:)
    template_mail(
      NQT_PLUS_ONE_SIT_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        start_url: start_url,
      },
    )
  end
end
