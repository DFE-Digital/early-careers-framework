# frozen_string_literal: true

class PartnershipNotificationJob < ApplicationJob
  def perform(partnership:)
    PartnershipNotificationService.new.notify(partnership)
  end
end
