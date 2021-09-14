# frozen_string_literal: true

class ParticipantDetailsReminderJob < ApplicationJob
  REMIND_TIME = 3.days

  def self.schedule(participant_profile)
    set(wait: REMIND_TIME).perform_later(profile_id: participant_profile.id)
  end

  def perform(profile_id:)
    profile = ParticipantProfile.find(profile_id)
    return if !profile || profile.withdrawn_record? || profile.completed_validation_wizard?

    ActiveRecord::Base.transaction do
      ParticipantMailer.add_details_reminder(participant_profile: profile).deliver_later
      profile.update_column(:request_for_details_sent_at, Time.zone.now)
      ParticipantDetailsReminderJob.schedule(profile)
    end
  end

  def send_reminder(profile)
    ParticipantMailer.add_details_reminder(participant_profile: profile).deliver_later
  end
end
