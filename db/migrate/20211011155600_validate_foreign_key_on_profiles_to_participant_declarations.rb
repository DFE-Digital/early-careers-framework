# frozen_string_literal: true

class ValidateForeignKeyOnProfilesToParticipantDeclarations < ActiveRecord::Migration[6.1]
  def change
    validate_foreign_key :participant_declarations, :participant_profiles
  end
end
