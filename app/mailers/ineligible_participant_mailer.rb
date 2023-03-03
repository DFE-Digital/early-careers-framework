# frozen_string_literal: true

class IneligibleParticipantMailer < ApplicationMailer
  ECT_PREVIOUS_INDUCTION_TEMPLATE = "e27eabc4-2d54-4356-8073-85cf9a559ce4"
  ECT_PREVIOUS_INDUCTION_PREVIOUSLY_ELIGIBLE_TEMPLATE = "1f8d7f15-b29d-4a2e-9a2c-57fb5fc9ca1f"
  ECT_EXEMPT_FROM_INDUCTION_TEMPLATE = "5b1fcc2a-c7fb-42e0-bbed-cf068d5dde39"
  ECT_EXEMPT_FROM_INDUCTION_TO_ECT_TEMPLATE = "529c7228-fadf-492b-a616-5cc0b3231eba"
  ECT_EXEMPT_FROM_INDUCTION_PREVIOUSLY_ELIGIBLE_TEMPLATE = "ec674fb7-21f3-4f92-b6ac-e21fe9902d62"
  ECT_EXEMPT_FROM_INDUCTION_TO_ECT_PREVIOUSLY_ELIGIBLE_TEMPLATE = "f74463f8-6d44-4af7-a397-9d472bd80601"
  ECT_NO_INDUCTION_TEMPLATE = "fa64f5de-a637-4f92-bf28-f43a223eba59"

  ACTIVE_FLAGS_TEMPLATES = {
    ect: "dcab5e33-c7c3-4d5a-84b6-458ae7640061",
    mentor: "f2b63f96-241f-480b-8825-299d5576ae59",
  }.freeze

  NO_QTS_TEMPLATES = {
    ect: "fbc5b291-68fd-42b6-bb9b-e09cac6affe5",
    mentor: "08f36052-4073-47c9-9dc7-ddf79ab5b371",
  }.freeze

  ECT_NOW_ELIGIBLE_PREVIOUS_INDUCTION_TEMPLATE = "ceca360c-985c-4518-aaf9-a9963fd39f45"

  def ect_active_flags_email
    participant_profile = params[:participant_profile]

    template_mail(
      ACTIVE_FLAGS_TEMPLATES[:ect],
      to: params[:induction_tutor_email],
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        ineligible_ECT_name: participant_profile.user.full_name,
      },
    ).tag(:ineligible_participant).associate_with(participant_profile, as: :participant_profile)
  end

  def mentor_active_flags_email
    participant_profile = params[:participant_profile]

    template_mail(
      ACTIVE_FLAGS_TEMPLATES[:mentor],
      to: params[:induction_tutor_email],
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        ineligible_mentor_name: participant_profile.user.full_name,
      },
    ).tag(:ineligible_participant).associate_with(participant_profile, as: :participant_profile)
  end

  def ect_no_qts_email
    participant_profile = params[:participant_profile]

    template_mail(
      NO_QTS_TEMPLATES[:ect],
      to: params[:induction_tutor_email],
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        ineligible_ECT_name: participant_profile.user.full_name,
      },
    ).tag(:ineligible_participant).associate_with(participant_profile, as: :participant_profile)
  end

  def mentor_no_qts_email
    participant_profile = params[:participant_profile]

    template_mail(
      NO_QTS_TEMPLATES[:mentor],
      to: params[:induction_tutor_email],
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        ineligible_mentor_name: participant_profile.user.full_name,
      },
    ).tag(:ineligible_participant).associate_with(participant_profile, as: :participant_profile)
  end

  def ect_previous_induction_email
    participant_profile = params[:participant_profile]

    template_mail(
      ECT_PREVIOUS_INDUCTION_TEMPLATE,
      to: params[:induction_tutor_email],
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        ineligible_ECT_name: participant_profile.user.full_name,
      },
    ).tag(:ineligible_participant).associate_with(participant_profile, as: :participant_profile)
  end

  def ect_previous_induction_email_previously_eligible
    participant_profile = params[:participant_profile]

    sit = Identity.find_user_by(email: induction_tutor_email)
    template_mail(
      ECT_PREVIOUS_INDUCTION_PREVIOUSLY_ELIGIBLE_TEMPLATE,
      to: params[:induction_tutor_email],
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        SIT_name: sit.full_name,
        ineligible_ECT_name: participant_profile.user.full_name,
      },
    ).tag(:ineligible_participant).associate_with(participant_profile, as: :participant_profile)
  end

  def ect_exempt_from_induction_email
    participant_profile = params[:participant_profile]
    induction_tutor_email = params[:induction_tutor_email]

    sit = Identity.find_user_by(email: induction_tutor_email)
    template_mail(
      ECT_EXEMPT_FROM_INDUCTION_TEMPLATE,
      to: induction_tutor_email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        SIT_name: sit.full_name,
        ineligible_ECT_name: participant_profile.user.full_name,
      },
    ).tag(:ineligible_participant).associate_with(participant_profile, as: :participant_profile)
  end

  def ect_exempt_from_induction_email_to_ect
    participant_profile = params[:participant_profile]

    template_mail(
      ECT_EXEMPT_FROM_INDUCTION_TO_ECT_TEMPLATE,
      to: participant_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        ineligible_ECT_name: participant_profile.user.full_name,
        school: participant_profile.school.name,
      },
    ).tag(:ineligible_participant_to_ect).associate_with(participant_profile, as: :participant_profile)
  end

  def ect_exempt_from_induction_email_previously_eligible
    participant_profile = params[:participant_profile]
    induction_tutor_email = params[:induction_tutor_email]

    sit = Identity.find_user_by(email: induction_tutor_email)
    template_mail(
      ECT_EXEMPT_FROM_INDUCTION_PREVIOUSLY_ELIGIBLE_TEMPLATE,
      to: induction_tutor_email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        SIT_name: sit.full_name,
        ineligible_ECT_name: participant_profile.user.full_name,
      },
    ).tag(:ineligible_participant).associate_with(participant_profile, as: :participant_profile)
  end

  def ect_exempt_from_induction_email_to_ect_previously_eligible
    participant_profile = params[:participant_profile]

    template_mail(
      ECT_EXEMPT_FROM_INDUCTION_TO_ECT_PREVIOUSLY_ELIGIBLE_TEMPLATE,
      to: participant_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        ineligible_ECT_name: participant_profile.user.full_name,
        school: participant_profile.school.name,
      },
    ).tag(:ineligible_participant_to_ect).associate_with(participant_profile, as: :participant_profile)
  end

  def ect_now_eligible_previous_induction_email
    participant_profile = params[:participant_profile]
    induction_tutor = params[:induction_tutor]

    template_mail(
      ECT_NOW_ELIGIBLE_PREVIOUS_INDUCTION_TEMPLATE,
      to: induction_tutor.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        fip_ect_name: participant_profile.user.full_name,
        sign_in: new_user_session_url,
        sit_name: induction_tutor.full_name,
      },
    ).tag(:now_eligible_previous_induction).associate_with(participant_profile, as: :participant_profile)
  end

  def ect_no_induction_email
    participant_profile = params[:participant_profile]
    induction_tutor_email = params[:induction_tutor_email]

    sit = Identity.find_user_by(email: induction_tutor_email)
    template_mail(
      ECT_NO_INDUCTION_TEMPLATE,
      to: induction_tutor_email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        FIP_ECT_name: participant_profile.user.full_name,
        sit_name: sit.full_name,
      },
    ).tag(:ineligible_participant).associate_with(participant_profile, as: :participant_profile)
  end
end
