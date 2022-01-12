# frozen_string_literal: true

class AddForeignKeyOnParticipantProfileToParticipantIdentity < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :participant_profiles, :participant_identities, null: false, validate: false
  end
end
