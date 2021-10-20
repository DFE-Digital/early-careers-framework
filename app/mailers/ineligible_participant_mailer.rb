# frozen_string_literal: true

class IneligibleParticipantMailer < ApplicationMailer
  ECT_PREVIOUS_INDUCTION_TEMPLATE = "e27eabc4-2d54-4356-8073-85cf9a559ce4"

  ACTIVE_FLAGS_TEMPLATES = {
    ect: "dcab5e33-c7c3-4d5a-84b6-458ae7640061",
    mentor: "f2b63f96-241f-480b-8825-299d5576ae59",
  }.freeze

  NO_QTS_TEMPLATES = {
    ect: "fbc5b291-68fd-42b6-bb9b-e09cac6affe5",
    mentor: "08f36052-4073-47c9-9dc7-ddf79ab5b371",
  }.freeze

  def ect_active_flags_email(induction_tutor_email:, participant_profile:)
    template_mail(
      ACTIVE_FLAGS_TEMPLATES[:ect],
      to: induction_tutor_email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        ineligible_ECT_name: participant_profile.user.full_name,
      },
    ).tag(:ineligible_participant).associate_with(participant_profile, as: :participant_profile)
  end

  def mentor_active_flags_email(induction_tutor_email:, participant_profile:)
    template_mail(
      ACTIVE_FLAGS_TEMPLATES[:mentor],
      to: induction_tutor_email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        ineligible_mentor_name: participant_profile.user.full_name,
      },
    ).tag(:ineligible_participant).associate_with(participant_profile, as: :participant_profile)
  end

  def ect_no_qts_email(induction_tutor_email:, participant_profile:)
    template_mail(
      NO_QTS_TEMPLATES[:ect],
      to: induction_tutor_email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        ineligible_ECT_name: participant_profile.user.full_name,
      },
    ).tag(:ineligible_participant).associate_with(participant_profile, as: :participant_profile)
  end

  def mentor_no_qts_email(induction_tutor_email:, participant_profile:)
    template_mail(
      NO_QTS_TEMPLATES[:mentor],
      to: induction_tutor_email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        ineligible_mentor_name: participant_profile.user.full_name,
      },
    ).tag(:ineligible_participant).associate_with(participant_profile, as: :participant_profile)
  end

  def ect_previous_induction_email(induction_tutor_email:, participant_profile:)
    template_mail(
      ECT_PREVIOUS_INDUCTION_TEMPLATE,
      to: induction_tutor_email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        ineligible_ECT_name: participant_profile.user.full_name,
        "NQT+1_materials_link": start_schools_year_2020_url(school_id: participant_profile.school.id),
      },
    ).tag(:ineligible_participant).associate_with(participant_profile, as: :participant_profile)
  end
end
