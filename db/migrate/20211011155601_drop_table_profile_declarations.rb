# frozen_string_literal: true

class DropTableProfileDeclarations < ActiveRecord::Migration[6.1]
  def up
    drop_table :profile_declarations
  end

  def down
    create_table :profile_declarations, id: :uuid do |t|
      t.references :participant_declaration, null: false, index: true
      t.references :participant_profile, null: false, index: true
      t.timestamps
    end
  end
end
