# frozen_string_literal: true

class AddDuplicateDeclarationOfToParticipantDeclaration < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      add_reference :participant_declarations, :superseded_by, foreign_key: { to_table: :participant_declarations }, index: { name: "superseded_by_index" }
    end
  end
end
