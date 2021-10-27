# frozen_string_literal: true

class ValidationRetryJob < ApplicationJob
  def perform
    ECFParticipantValidationData.where(api_failure: true).find_each do |validation_data|
      ValidateParticipant.call(participant_profile: validation_data.participant_profile,
                               config: { check_first_name_only: true })
    rescue StandardError => e
      Rails.logger.error("Problem with DQT API on retry: #{e.message}")
      Sentry.capture_message("Problem with DQT API on retry: #{e.message}")
      next
    end
  end
end
