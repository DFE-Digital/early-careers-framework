# frozen_string_literal: true

class ParticipantMailer < ApplicationMailer
  PARTICIPANT_REMOVED_BY_STI = "ab8fb8b1-9f44-4d27-8e80-01d5d70d22f6"

  PARTICIPANT_TEMPLATES = {
    ect_cip: "3bfad27e-e7af-4b53-94cb-af36362f43d8",
    ect_fip: "3d3dbe1a-5836-4781-836f-e546beae253e",
    mentor_cip: "3721ec20-ba5a-4424-8114-0e009b5bdbda",
    mentor_fip: "ba3d4caf-5ef8-4a14-9e79-b7719780da09",
    sit_mentor_cip: "7aa80a9c-e486-42e8-92c8-7f970459d37d",
    sit_mentor_fip: "0b7f850f-f26a-4e62-9fc5-17fbd8286e49",
    fip_preterm_reminder: "12969797-c110-436d-b10b-7f7d08d4d9df",
    cip_preterm_reminder: "623cb545-1bc4-4407-94a1-474e2a080e39",
  }.freeze

  def participant_added(participant_profile:)
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

  def participant_removed_by_sti(participant_profile:, sti_profile:)
    template_mail(
      PARTICIPANT_REMOVED_BY_STI,
      to: participant_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        subject: "You have been removed from early career teacher training",
        name: participant_profile.user.full_name,
        school_name: participant_profile.school.name,
        sti_name: sti_profile.user.full_name,
      },
    ).tag(:participant_removed).associate_with(participant_profile, as: :participant_profile)
  end

  def add_details_reminder(participant_profile:)
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

  def fip_preterm_reminder(induction_coordinator_profile:, season:)
    template_mail(
      PARTICIPANT_TEMPLATES[:fip_preterm_reminder],
      to: induction_coordinator_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        season: season,
        name: induction_coordinator_profile.user.full_name,
        school_name: induction_coordinator_profile.school.name,
        sign_in: new_user_sign_in_url,
      },
    ).tag(:fip_preterm_reminder).associate_with(induction_coordinator_profile, as: :induction_coordinator_profile)
  end

  def cip_preterm_reminder(induction_coordinator_profile:, season:)
    template_mail(
      PARTICIPANT_TEMPLATES[:cip_preterm_reminder],
      to: induction_coordinator_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        season: season,
        name: induction_coordinator_profile.user.full_name,
        school_name: induction_coordinator_profile.school.name,
        sign_in: new_user_sign_in_url,
      },
    ).tag(:cip_preterm_reminder).associate_with(induction_coordinator_profile, as: :induction_coordinator_profile)
  end

private

  def template_type_for(profile)
    type = profile.participant_type
    type = :sit_mentor if type == :mentor && profile.user.induction_coordinator?
    "#{type}_#{profile.school_cohort.cip? ? 'cip' : 'fip'}".to_sym
  end

  def what_each_person_does_url
    Rails.application.routes.url_helpers.page_url(page: :"what-each-person-does",
                                                  host: Rails.application.config.domain,
                                                  **UTMService.email(:participant_validation_invitation))
  end
end
