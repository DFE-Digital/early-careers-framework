# frozen_string_literal: true

class Analytics::UpsertParticipantProfileJob < ApplicationJob
  def perform(participant_profile:)
    Analytics::ECFValidationService.upsert_record(participant_profile)
  end
end
