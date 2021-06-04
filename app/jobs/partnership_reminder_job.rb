# frozen_string_literal: true

class PartnershipReminderJob < ApplicationJob
  def perform(partnership:, report_id:)
    return if partnership.challenged? || partnership.report_id != report_id

    PartnershipNotificationService.new.send_reminder(partnership)
  end
end
