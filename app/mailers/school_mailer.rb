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
  COORDINATOR_SIGN_IN_CHASER_EMAIL_TEMPLATE = "b5c318a4-2171-4ded-809a-af72dd87e7a7"
  COORDINATOR_REMINDER_TO_CHOOSE_ROUTE_EMAIL_TEMPLATE = "c939c27a-9951-4ac3-817d-56b7bf343fb4"
  COORDINATOR_REMINDER_TO_CHOOSE_PROVIDER_EMAIL_TEMPLATE = "e7a60b68-334e-4a25-8adf-55ebc70622f9"
  COORDINATOR_REMINDER_TO_CHOOSE_MATERIALS_EMAIL_TEMPLATE = "43baf25c-6a46-437b-9f30-77c57d68a59e"
  ADD_PARTICIPANTS_EMAIL_TEMPLATE = "721787d0-74bc-42a0-a064-ee0c1cb58edb"
  YEAR2020_INVITE_EMAIL_TEMPLATE = "d4b53e26-4630-43a5-b89e-3c668061a41c"
  BASIC_TEMPLATE = "b1ab542e-a8d5-4fdf-a7aa-f0ce49b98262"

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

  def nomination_confirmation_email(user:, school:, start_url:)
    template_mail(
      NOMINATION_CONFIRMATION_EMAIL_TEMPLATE,
      to: user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school.name,
        start_url: start_url,
        subject: "Sign in to manage induction",
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

  def induction_coordinator_reminder_to_choose_provider_email(recipient:, name:, school_name:, sign_in_url:)
    template_mail(
      COORDINATOR_REMINDER_TO_CHOOSE_PROVIDER_EMAIL_TEMPLATE,
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

  def year2020_invite_email(recipient:, start_url:)
    template_mail(
      YEAR2020_INVITE_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        start_url: start_url,
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
end
