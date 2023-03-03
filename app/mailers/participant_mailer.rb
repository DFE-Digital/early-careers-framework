# frozen_string_literal: true

class ParticipantMailer < ApplicationMailer
  PARTICIPANT_REMOVED_BY_SIT = "ab8fb8b1-9f44-4d27-8e80-01d5d70d22f6"

  PARTICIPANT_TEMPLATES = {
    ect_cip: "3bfad27e-e7af-4b53-94cb-af36362f43d8",
    ect_fip: "3d3dbe1a-5836-4781-836f-e546beae253e",
    mentor_cip: "3721ec20-ba5a-4424-8114-0e009b5bdbda",
    mentor_fip: "ba3d4caf-5ef8-4a14-9e79-b7719780da09",
    sit_mentor_cip: "7aa80a9c-e486-42e8-92c8-7f970459d37d",
    sit_mentor_fip: "0b7f850f-f26a-4e62-9fc5-17fbd8286e49",
    fip_register_participants_reminder: "12969797-c110-436d-b10b-7f7d08d4d9df",
    cip_register_participants_reminder: "623cb545-1bc4-4407-94a1-474e2a080e39",
    ect_fip_added_and_validated: "93fba542-f118-4855-9509-83583f251eab",
    mentor_fip_added_and_validated: "f71fa01a-ecc2-49e5-999b-48ff0070e13a",
    ect_cip_added_and_validated: "b0d58248-c49e-4ec6-bca2-2c4cf151c421",
    mentor_cip_added_and_validated: "1396072b-4dc7-473d-aef7-22e674e42874",
    preterm_reminder: "3bece922-871e-49a9-88a1-83eeb8821ab1",
    preterm_reminder_unconfirmed_for_2022: "0556f857-39b2-4a86-8a79-f42c91cd9a6b",
    sit_contact_address_bounce: "c414ed7d-a3ef-43f0-a452-ee1a5f376fcc",
  }.freeze

  def participant_added
    participant_profile = params[:participant_profile]

    template_mail(
      PARTICIPANT_TEMPLATES[template_type_for participant_profile],
      to: participant_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        subject: "We need information for your early career teacher training programme",
        name: participant_profile.user.full_name,
        school_name: participant_profile.school.name,
        participant_start: new_user_session_url(**UTMService.email(:participant_validation_invitation)),
        roles_guidance: what_each_person_does_url,
        reminder: "no",
      },
    ).tag(:request_for_details).associate_with(participant_profile, as: :participant_profile)
  end

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

  def add_details_reminder
    participant_profile = params[:participant_profile]

    template_mail(
      PARTICIPANT_TEMPLATES[template_type_for participant_profile],
      to: participant_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        subject: "Reminder: add information to start your early career teacher training",
        name: participant_profile.user.full_name,
        school_name: participant_profile.school.name,
        participant_start: new_user_session_url(**UTMService.email(:participant_validation_invitation)),
        roles_guidance: what_each_person_does_url,
        reminder: "yes",
      },
    ).tag(:request_for_details).associate_with(participant_profile, as: :participant_profile)
  end

  def preterm_reminder
    induction_coordinator_profile = params[:induction_coordinator_profile]

    template_mail(
      PARTICIPANT_TEMPLATES[:preterm_reminder],
      to: induction_coordinator_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name: induction_coordinator_profile.user.full_name,
        sign_in: new_user_session_url(**UTMService.email(:preterm_reminder)),
      },
    ).tag(:preterm_reminder).associate_with(induction_coordinator_profile, as: :induction_coordinator_profile)
  end

  def preterm_reminder_unconfirmed_for_2022
    induction_coordinator_profile = params[:induction_coordinator_profile]

    template_mail(
      PARTICIPANT_TEMPLATES[:preterm_reminder_unconfirmed_for_2022],
      to: induction_coordinator_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name: induction_coordinator_profile.user.full_name,
        sign_in: new_user_session_url(**UTMService.email(:preterm_reminder_unconfirmed_for_2022)),
      },
    ).tag(:preterm_reminder_unconfirmed_for_2022).associate_with(induction_coordinator_profile, as: :induction_coordinator_profile)
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

  def sit_contact_address_bounce
    induction_coordinator_profile = params[:induction_coordinator_profile]
    school = params[:school]

    email_address = school.primary_contact_email || school.secondary_contact_email

    template_mail(
      PARTICIPANT_TEMPLATES[:sit_contact_address_bounce],
      to: email_address,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school.name,
        induction_coordinator_profile_email: induction_coordinator_profile.user.email,
      },
    ).tag(:sit_contact_address_bounce).associate_with(school, as: :school)
  end

  def sit_has_added_and_validated_participant
    participant_profile = params[:participant_profile]
    school_name = params[:school_name]

    template_mail(
      PARTICIPANT_TEMPLATES[sit_validation_template participant_profile],
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
