# frozen_string_literal: true

# NOTE: These are currently all for FIP <> FIP.
class ParticipantTransferMailer < ApplicationMailer
  # participant_transfer_out_notification
  TRANSFER_OUT_FOR_ECT_TEMPLATE         = "7d46c3d2-bf80-4b48-a8cd-94902bbb31b8"
  TRANSFER_OUT_FOR_MENTOR_TEMPLATE      = "5341d978-1d81-45d7-9734-4f799f6742ab"

  # participant_transfer_in_notification
  TRANSFER_IN_FOR_ECT_TEMPLATE          = "1f7baa1d-d684-4499-be8c-7cdeaa967f1b"
  TRANSFER_IN_FOR_MENTOR_TEMPLATE       = "19bd6887-0313-4e74-8945-5c8f627fec97"

  # provider_transfer_out_notification
  TRANSFER_OUT_FOR_PROVIDER_TEMPLATE    = "17d23e1f-9e71-4f27-8b33-33c05958c566"

  # provider_transfer_in_notification
  TRANSFER_IN_FOR_PROVIDER_TEMPLATE     = "2de35ce5-aad9-48e0-bbe2-21ae50161c33"

  # provider_new_school_transfer_notification
  NEW_SCHOOL_TRANSFER_FOR_PROVIDER      = "6c121b9d-a30b-4246-904f-e09b4b9aab7a"

  # provider_existing_school_transfer_notification
  EXISTING_SCHOOL_TRANSFER_FOR_PROVIDER = "80cae2bf-658b-44ed-b3f6-337cc77fb953"

  # induction_coordinator_participant_transfer_out_notification
  SIT_TRANSFER_OUT_FOR_ECT              = "02b2d0a0-96c6-4596-9aad-17f8e5ff9883"
  SIT_TRANSFER_OUT_FOR_MENTOR           = "6b6b6358-e6df-40c2-b6b1-00ab52943c44"

  # This mailer switches on ECT and mentor-specific templates, though the inputs are the same,
  # there are minor copy changes between the templates.
  #
  # Reference: 1, 2
  def participant_transfer_out_notification(induction_record:)
    participant_profile = induction_record.participant_profile
    preferred_identity_email = induction_record.preferred_identity.email

    template_id = if induction_record.participant_profile.ect?
                    TRANSFER_OUT_FOR_ECT_TEMPLATE
                  else
                    TRANSFER_OUT_FOR_MENTOR_TEMPLATE
                  end

    template_mail(
      template_id,
      to: preferred_identity_email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        transferring_ppt_name: participant_profile.user.full_name,
        current_school_name: induction_record.school.name,
      },
    ).tag(:participant_transfer_out_notification).associate_with(participant_profile, as: :participant_profile)
  end

  # This mailer switches on ECT and mentor-specific templates, though the inputs are the same,
  # there are minor copy changes between the templates.
  #
  # Reference: 3, 4
  def participant_transfer_in_notification(induction_record:)
    participant_profile = induction_record.participant_profile
    preferred_identity_email = induction_record.preferred_identity.email

    template_id = if participant_profile.ect?
                    TRANSFER_IN_FOR_ECT_TEMPLATE
                  else
                    TRANSFER_IN_FOR_MENTOR_TEMPLATE
                  end

    template_mail(
      template_id,
      to: preferred_identity_email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        transferring_ppt_name: participant_profile.user.full_name,
        joining_date: induction_record.start_date.to_date.to_s(:govuk),
        new_school_name: induction_record.school.name,
      },
    ).tag(:participant_transfer_in_notification).associate_with(participant_profile, as: :participant_profile)
  end

  # Sent to the *outgoing* lead provider, when it changes.
  #
  # Reference: 5
  def provider_transfer_out_notification(induction_record:, lead_provider_profile:)
    template_mail(
      TRANSFER_OUT_FOR_PROVIDER_TEMPLATE,
      to: lead_provider_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        joining_date: induction_record.start_date.to_date.to_s(:govuk),
        external_participant_id: induction_record.participant_profile.participant_identity.new_external_identifier,
      },
    ).tag(:provider_transfer_out_notification).associate_with(lead_provider_profile, as: :lead_provider_profile)
  end

  # Sent to the *incoming* lead provider, when it has changed.
  #
  # Reference: 6
  def provider_transfer_in_notification(induction_record:, lead_provider_profile:)
    template_mail(
      TRANSFER_IN_FOR_PROVIDER_TEMPLATE,
      to: lead_provider_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        joining_date: induction_record.start_date.to_date.to_s(:govuk),
        external_participant_id: induction_record.participant_profile.participant_identity.new_external_identifier,
      },
    ).tag(:provider_transfer_in_notification).associate_with(lead_provider_profile, as: :lead_provider_profile)
  end

  # Sent to the lead provider when a participant changes school, but remains with their
  # current lead provider.
  #
  # Reference: 7
  def provider_new_school_transfer_notification(induction_record:, lead_provider_profile:)
    template_mail(
      NEW_SCHOOL_TRANSFER_FOR_PROVIDER,
      to: lead_provider_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        joining_date: induction_record.start_date.to_date.to_s(:govuk),
        external_participant_id: induction_record.participant_profile.participant_identity.new_external_identifier,
      },
    ).tag(:provider_new_school_transfer_notification).associate_with(lead_provider_profile, as: :lead_provider_profile)
  end

  # Sent to when the LP is already the *outgoing* and *incoming* lead provider at both schools.
  #
  # Reference: 8
  def provider_existing_school_transfer_notification(induction_record:, lead_provider_profile:)
    template_mail(
      EXISTING_SCHOOL_TRANSFER_FOR_PROVIDER,
      to: lead_provider_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        joining_date: induction_record.start_date.to_s(:govuk),
        external_participant_id: induction_record.participant_profile.participant_identity.new_external_identifier,
      },
    ).tag(:provider_existing_school_transfer_notification).associate_with(lead_provider_profile, as: :lead_provider_profile)
  end

  # This mailer switches on ECT and mentor-specific templates, though the inputs are the same,
  # there are minor copy changes between the templates.
  #
  # Sent to a School Induction Coordinator when an ECT or mentor *has* transferred to a new school. This is
  # to be sent *after* the transfer has happened.
  #
  # Reference: 9, 10
  def induction_coordinator_participant_transfer_out_notification(induction_record:, induction_coordinator_profile:)
    participant_profile = induction_record.participant_profile

    template_id = if participant_profile.ect?
                    SIT_TRANSFER_OUT_FOR_ECT
                  else
                    SIT_TRANSFER_OUT_FOR_MENTOR
                  end

    template_mail(
      template_id,
      to: induction_coordinator_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        sit_name: induction_coordinator_profile.user.name,
        transferring_ppt_name: participant_profile.user.full_name,
        new_school_name: induction_record.school.urn,
      },
    ).tag(:induction_coordinator_participant_transfer_out_notification).associate_with(induction_coordinator_profile, as: :induction_coordinator_profile)
  end
end
