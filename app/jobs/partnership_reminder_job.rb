# frozen_string_literal: true

class PartnershipReminderJob < ApplicationJob
  def perform(partnership)
    return if partnership.challenged?

    PartnershipNotificationService.new.send_reminder(partnership)
  end
end
