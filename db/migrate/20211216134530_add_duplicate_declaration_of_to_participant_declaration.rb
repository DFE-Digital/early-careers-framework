class AddDuplicateDeclarationOfToParticipantDeclaration < ActiveRecord::Migration[6.1]

  def change
    safety_assured do
      add_reference :participant_declarations, :original_participant_declaration, foreign_key: { to_table: :participant_declarations }, index: { name: "original_participant_declaration_index" }
    end
  end
end
