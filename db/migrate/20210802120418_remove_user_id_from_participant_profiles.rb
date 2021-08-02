class RemoveUserIdFromParticipantProfiles < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_reference :participant_profiles, :user, index: true, foreign_key: true
    end
  end
end
