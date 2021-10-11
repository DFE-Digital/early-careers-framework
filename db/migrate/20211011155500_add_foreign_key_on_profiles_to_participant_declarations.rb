# frozen_string_literal: true

class AddForeignKeyOnProfilesToParticipantDeclarations < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :participant_declarations, :participant_profiles, null: false, validate: false
  end
end
