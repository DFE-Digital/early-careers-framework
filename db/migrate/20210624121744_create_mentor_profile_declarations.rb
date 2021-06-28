# frozen_string_literal: true

class CreateMentorProfileDeclarations < ActiveRecord::Migration[6.1]
  def change
    create_table :mentor_profile_declarations do |t|
      t.references :participant_declaration, null: false, index: { name: :participant_declaration_mentor_declarations }
      t.references :mentor_profile, null: false, foreign_key: true, index: { name: :participant_declarations_mentor_profile_id }
      t.timestamps
    end
  end
end
