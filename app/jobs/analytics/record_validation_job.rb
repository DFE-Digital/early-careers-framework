# frozen_string_literal: true

class Analytics::RecordValidationJob < ApplicationJob
  def perform(participant_profile:, real_time_attempts:, real_time_success:, nino_entered:)
    # Analytics::ECFValidationService.record_validation(
    #   participant_profile:,
    #   real_time_attempts:,
    #   real_time_success:,
    #   nino_entered:,
    # )
  end
end
