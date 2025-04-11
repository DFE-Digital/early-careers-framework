# frozen_string_literal: true

class Analytics::UpsertECFParticipantProfileJob < ApplicationJob
  def perform(participant_profile_id:)
    participant_profile = ParticipantProfile::ECF.find_by(id: participant_profile_id)
    Analytics::ECFValidationService.upsert_record(participant_profile) if participant_profile
  end
end
