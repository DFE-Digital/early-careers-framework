class ReplaceParticipantIdentitiesWithIdentities < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :participant_profiles, :participant_identities
    remove_foreign_key :npq_applications, :participant_identities

    add_foreign_key :participant_profiles, :identities, validate: false, column: :participant_identity_id
    add_foreign_key :npq_applications, :identities, validate: false, column: :participant_identity_id
  end
end
