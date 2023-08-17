# frozen_string_literal: true

class ParticipantMailer < ApplicationMailer
  PARTICIPANT_REMOVED_BY_SIT = "ab8fb8b1-9f44-4d27-8e80-01d5d70d22f6"

  PARTICIPANT_TEMPLATES = {
    fip_register_participants_reminder: "12969797-c110-436d-b10b-7f7d08d4d9df",
    cip_register_participants_reminder: "623cb545-1bc4-4407-94a1-474e2a080e39",
    ect_fip_added_and_validated: "93fba542-f118-4855-9509-83583f251eab",
    mentor_fip_added_and_validated: "f71fa01a-ecc2-49e5-999b-48ff0070e13a",
    ect_cip_added_and_validated: "b0d58248-c49e-4ec6-bca2-2c4cf151c421",
    mentor_cip_added_and_validated: "1396072b-4dc7-473d-aef7-22e674e42874",
  }.freeze

  def participant_removed_by_sit
    participant_profile = params[:participant_profile]
    sit_name = params[:sit_name]

    template_mail(
      PARTICIPANT_REMOVED_BY_SIT,
      to: participant_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        subject: "You have been removed from early career teacher training",
        name: participant_profile.user.full_name,
        school_name: participant_profile.school.name,
        sti_name: sit_name,
      },
    ).tag(:participant_removed).associate_with(participant_profile, as: :participant_profile)
  end

  def fip_register_participants_reminder
    induction_coordinator_profile = params[:induction_coordinator_profile]
    school_name = params[:school_name]

    template_mail(
      PARTICIPANT_TEMPLATES[:fip_register_participants_reminder],
      to: induction_coordinator_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name: induction_coordinator_profile.user.full_name,
        school_name:,
        sign_in: new_user_session_url,
      },
    ).tag(:fip_register_participants_reminder).associate_with(induction_coordinator_profile, as: :induction_coordinator_profile)
  end

  def cip_register_participants_reminder
    induction_coordinator_profile = params[:induction_coordinator_profile]
    school_name = params[:school_name]

    template_mail(
      PARTICIPANT_TEMPLATES[:cip_register_participants_reminder],
      to: induction_coordinator_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name: induction_coordinator_profile.user.full_name,
        school_name:,
        sign_in: new_user_session_url,
      },
    ).tag(:cip_register_participants_reminder).associate_with(induction_coordinator_profile, as: :induction_coordinator_profile)
  end

  def sit_has_added_and_validated_participant
    participant_profile = params[:participant_profile]
    school_name = params[:school_name]

    template_id = PARTICIPANT_TEMPLATES[sit_validation_template participant_profile]
    return if template_id.blank?

    template_mail(
      template_id,
      to: participant_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        ppt_name: participant_profile.user.full_name,
        school: school_name,
      },
    ).tag(:sit_has_added_and_validated_participant).associate_with(participant_profile, as: :participant_profile)
  end

private

  def template_type_for(profile)
    type = profile.participant_type
    type = :sit_mentor if type == :mentor && profile.user.induction_coordinator?
    "#{type}_#{profile.school_cohort.cip? ? 'cip' : 'fip'}".to_sym
  end

  def sit_validation_template(profile)
    type_and_programme = template_type_for profile
    "#{type_and_programme}_added_and_validated".to_sym
  end

  def what_each_person_does_url
    Rails.application.routes.url_helpers.page_url(page: :"what-each-person-does",
                                                  host: Rails.application.config.domain,
                                                  **UTMService.email(:participant_validation_invitation))
  end
end
