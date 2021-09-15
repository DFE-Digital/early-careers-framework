# frozen_string_literal: true

class ParticipantMailer < ApplicationMailer
  PARTICIPANT_REMOVED_BY_STI = "ab8fb8b1-9f44-4d27-8e80-01d5d70d22f6"

  PARTICIPANT_ADDED_TEMPLATES = {
    ect: "50ee41e5-06b9-41cf-9afd-d5bc4db356c4",
    mentor: "e0198213-c09d-41aa-8197-b167e495e49d",
    sit_mentor: "7e7d3fdb-41f5-4e04-a4ae-acf92e8fefe6",
  }.freeze

  DETAIL_REMINDER_TEMPLATES = {
    ect: "0bf633c3-54c9-4150-b1fb-57748376aed1",
    mentor: "691eb49b-f23f-49dd-b799-f8efdd5e010f",
    sit_mentor: "fcf85c00-6d96-48a6-bf27-ea09c61f0eee",
  }.freeze

  def participant_added(participant_profile:)
    template_mail(
      PARTICIPANT_ADDED_TEMPLATES[template_type_for participant_profile],
      to: participant_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        subject: "We need information for your early career teacher training programme",
        name: participant_profile.user.full_name,
        school_name: participant_profile.school.name,
        participant_start: new_user_session_url,
      },
    )
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
    )
  end

  def add_details_reminder(participant_profile:)
    template_mail(
      DETAIL_REMINDER_TEMPLATES[template_type_for participant_profile],
      to: participant_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        subject: "Reminder: add information to start your early career teacher training",
        name: participant_profile.user.full_name,
        school_name: participant_profile.school.name,
        participant_start: new_user_session_url,
      },
    )
  end

private

  def template_type_for(profile)
    type = profile.participant_type
    type = :sit_mentor if type == :mentor && profile.user.induction_coordinator?
    type
  end
end
