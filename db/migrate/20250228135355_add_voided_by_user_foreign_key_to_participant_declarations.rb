# frozen_string_literal: true

class AddVoidedByUserForeignKeyToParticipantDeclarations < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :participant_declarations, :users, column: :voided_by_user_id, validate: false
  end
end
