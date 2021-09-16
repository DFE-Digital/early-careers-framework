# frozen_string_literal: true

class ValidationRetryJob < CronJob
  self.cron_expression = "15 3 * * *"

  queue_as :validation_retry

  def perform
    ECFParticipantValidationData.where(api_failure: true).find_each do |validation_data|
      ValidateParticipant.call(participant_profile: validation_data.participant_profile,
                               config: { check_first_name_only: true })
    rescue StandardError => e
      Rails.logger.error("Problem with DQT API on retry: " + e.message)
      Sentry.capture_message("Problem with DQT API on retry: " + e.message)
      next
    end
  end
end
