# frozen_string_literal: true

class ValidateForeignKeyOnParticipantDeclarationsToMentorUsers < ActiveRecord::Migration[6.1]
  def change
    validate_foreign_key :participant_declarations, :users, column: :mentor_user_id
  end
end
