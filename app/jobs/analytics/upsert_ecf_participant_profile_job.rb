# frozen_string_literal: true

class Analytics::UpsertECFParticipantProfileJob < ApplicationJob
  def perform(participant_profile:)
    # Analytics::ECFValidationService.upsert_record(participant_profile)
  end
end
