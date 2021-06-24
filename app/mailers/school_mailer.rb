# frozen_string_literal: true

class SchoolMailer < ApplicationMailer
  NOMINATION_EMAIL_TEMPLATE = "a7cc4d19-c0cb-4187-a71b-1b1ea029924f"
  NOMINATION_CONFIRMATION_EMAIL_TEMPLATE = "240c5685-5cb0-40a9-9bd4-1a595d991cbc"
  SCHOOL_PARTNERSHIP_NOTIFICATION_EMAIL_TEMPLATE = "99991fd9-fb41-48cf-846d-98a1fee7762a"
  COORDINATOR_PARTNERSHIP_NOTIFICATION_EMAIL_TEMPLATE = "076e8486-cbcc-44ee-8a6e-d2a721ee1460"
  MINISTERIAL_LETTER_EMAIL_TEMPLATE = "f1310917-aa50-4789-b8c2-8cc5e9b91485"
  BETA_INVITE_EMAIL_TEMPLATE = "0ae827de-3caa-4a93-b464-c434cbbd02c0"
  MAT_INVITE_EMAIL_TEMPLATE = "f856f50e-6f49-441e-8018-f8303367eb5c"

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
    cohort:,
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
        provider_name: lead_provider_name, # TODO: remove once template updated
        lead_provider_name: lead_provider_name,
        delivery_partner_name: delivery_partner_name,
        cohort: cohort,
        school_name: school_name,
        nominate_url: nominate_url,
        challenge_url: challenge_url,
        challenge_deadline: challenge_deadline,
        subject: "Provider confirmed",
      },
    )
  end

  def coordinator_partnership_notification_email(
    recipient:,
    lead_provider_name:,
    delivery_partner_name:,
    cohort:,
    school_name:,
    start_url:,
    challenge_url:,
    challenge_deadline:
  )
    template_mail(
      COORDINATOR_PARTNERSHIP_NOTIFICATION_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        provider_name: lead_provider_name, # TODO: remove once template updated
        lead_provider_name: lead_provider_name,
        delivery_partner_name: delivery_partner_name,
        cohort: cohort,
        school_name: school_name,
        start_url: start_url,
        challenge_url: challenge_url,
        challenge_deadline: challenge_deadline,
        subject: "Provider confirmed",
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
end
