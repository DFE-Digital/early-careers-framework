# frozen_string_literal: true

class DeleteNPQParticipantProfiles < ActiveRecord::Migration[7.1]
  def up
    npq_type = "ParticipantProfile::NPQ"

    ParticipantProfileState.includes(:participant_profile).where(participant_profile: { type: npq_type }).in_batches(of: 10_000) { |batch| batch.delete_all }
    ParticipantProfileSchedule.includes(:participant_profile).where(participant_profile: { type: npq_type }).in_batches(of: 10_000) { |batch| batch.delete_all }
    ProfileValidationDecision.includes(:participant_profile).where(participant_profile: { type: npq_type }).in_batches(of: 10_000) { |batch| batch.delete_all }
    ParticipantProfile.where(type: npq_type).in_batches(of: 10_000) { |batch| batch.delete_all }
  end
end
