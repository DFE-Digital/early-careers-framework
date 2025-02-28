# frozen_string_literal: true

class ValidateParticipantDeclarationsVoidedByUserForeignKey < ActiveRecord::Migration[7.1]
  def change
    validate_foreign_key :participant_declarations, :users, column: :voided_by_user_id
  end
end
