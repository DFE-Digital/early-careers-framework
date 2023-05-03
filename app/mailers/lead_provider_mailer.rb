# frozen_string_literal: true

class LeadProviderMailer < ApplicationMailer
  WELCOME_EMAIL_TEMPLATE = "07773cdf-9db6-4880-9ac6-ab4454a71d65"
  PARTNERSHIP_CHALLENGED_TEMPLATE_ID = "01c1ab30-1a45-4ce7-b994-e4df8334f23b"
  PROGRAMME_CHANGED_TEMPLATE_ID = "821c3b28-27a7-4ed4-9d1f-58e8f341dac7"

  def welcome_email
    user = params[:user]
    lead_provider_name = params[:lead_provider_name]
    start_url = params[:start_url]

    template_mail(
      WELCOME_EMAIL_TEMPLATE,
      to: user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name: user.full_name,
        lead_provider_name:,
        start_url:,
        subject: "Your account to confirm schools",
      },
    ).tag(:lead_provider_account_created)
  end

  def partnership_challenged_email
    partnership = params[:partnership]
    user = params[:user]

    reason = I18n.t(partnership.challenge_reason, scope: "partnerships.challenge_reasons")
    lead_provider_name = partnership.lead_provider.name

    template_mail(
      PARTNERSHIP_CHALLENGED_TEMPLATE_ID,
      to: user.email,
      rails_mailer: mailer_name,
      rails_mailer_template: action_name,
      personalisation: {
        name: user.full_name,
        school_name: partnership.school.name,
        school_urn: partnership.school.urn,
        delivery_partner_name: partnership.delivery_partner.name,
        lead_provider_name:,
        cohort_year: partnership.cohort.academic_year,
        reason:,
      },
    ).tag(:partnership_challenged).associate_with(partnership)
  end

  def programme_changed_email
    partnership = params[:partnership]
    user = params[:user]
    cohort_year = params[:cohort_year]
    what_changes_choice = params[:what_changes_choice]

    lead_provider_name = partnership.lead_provider.name
    delivery_partner_name = partnership.delivery_partner.name

    reason = I18n.t(what_changes_choice, scope: "programme_changed_reasons",
                                         lead_provider_name:,
                                         delivery_partner_name:)

    template_mail(
      PROGRAMME_CHANGED_TEMPLATE_ID,
      to: user.email,
      rails_mailer: mailer_name,
      rails_mailer_template: action_name,
      personalisation: {
        name: user.full_name,
        school_name: partnership.school.name,
        school_urn: partnership.school.urn,
        delivery_partner_name:,
        cohort_year:,
        lead_provider_name:,
        reason:,
      },
    ).tag(:fip_programme_changed)
  end
end
