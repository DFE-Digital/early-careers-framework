# frozen_string_literal: true

# NOTE: These are currently all for FIP <> FIP.
class ParticipantTransferMailer < ApplicationMailer
  # provider_transfer_out_notification
  TRANSFER_OUT_FOR_PROVIDER_TEMPLATE    = "17d23e1f-9e71-4f27-8b33-33c05958c566"

  # provider_transfer_in_notification
  TRANSFER_IN_FOR_PROVIDER_TEMPLATE     = "2de35ce5-aad9-48e0-bbe2-21ae50161c33"

  # provider_new_school_transfer_notification
  NEW_SCHOOL_TRANSFER_FOR_PROVIDER      = "6c121b9d-a30b-4246-904f-e09b4b9aab7a"

  # provider_existing_school_transfer_notification
  EXISTING_SCHOOL_TRANSFER_FOR_PROVIDER = "80cae2bf-658b-44ed-b3f6-337cc77fb953"

  # Sent to the *outgoing* lead provider, when it changes.
  #
  # Reference: 5
  def provider_transfer_out_notification
    induction_record = params[:induction_record]
    lead_provider_profile = params[:lead_provider_profile]

    template_mail(
      TRANSFER_OUT_FOR_PROVIDER_TEMPLATE,
      to: lead_provider_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        joining_date: induction_record.start_date.to_date.to_fs(:govuk),
        external_participant_id: induction_record.participant_profile.participant_identity.user_id,
      },
    ).tag(:provider_transfer_out_notification).associate_with(lead_provider_profile, as: :lead_provider_profile)
  end

  # Sent to the *incoming* lead provider, when it has changed.
  #
  # Reference: 6
  def provider_transfer_in_notification
    induction_record = params[:induction_record]
    lead_provider_profile = params[:lead_provider_profile]

    template_mail(
      TRANSFER_IN_FOR_PROVIDER_TEMPLATE,
      to: lead_provider_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        joining_date: induction_record.start_date.to_date.to_fs(:govuk),
        external_participant_id: induction_record.participant_profile.participant_identity.user_id,
      },
    ).tag(:provider_transfer_in_notification).associate_with(lead_provider_profile, as: :lead_provider_profile)
  end

  # Sent to the lead provider when a participant changes school, but remains with their
  # current lead provider.
  #
  # Reference: 7
  def provider_new_school_transfer_notification
    induction_record = params[:induction_record]
    lead_provider_profile = params[:lead_provider_profile]

    template_mail(
      NEW_SCHOOL_TRANSFER_FOR_PROVIDER,
      to: lead_provider_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        joining_date: induction_record.start_date.to_date.to_fs(:govuk),
        external_participant_id: induction_record.participant_profile.participant_identity.user_id,
      },
    ).tag(:provider_new_school_transfer_notification).associate_with(lead_provider_profile, as: :lead_provider_profile)
  end

  # Sent to when the LP is already the *outgoing* and *incoming* lead provider at both schools.
  #
  # Reference: 8
  def provider_existing_school_transfer_notification
    induction_record = params[:induction_record]
    lead_provider_profile = params[:lead_provider_profile]

    template_mail(
      EXISTING_SCHOOL_TRANSFER_FOR_PROVIDER,
      to: lead_provider_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        joining_date: induction_record.start_date.to_fs(:govuk),
        external_participant_id: induction_record.participant_profile.participant_identity.user_id,
      },
    ).tag(:provider_existing_school_transfer_notification).associate_with(lead_provider_profile, as: :lead_provider_profile)
  end
end
