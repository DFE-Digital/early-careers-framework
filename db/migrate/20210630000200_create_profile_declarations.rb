# frozen_string_literal: true

class CreateProfileDeclarations < ActiveRecord::Migration[6.1]
  def change
    create_table :profile_declarations, id: :uuid do |t|
      t.references :participant_declaration, null: false, index: true
      t.references :lead_provider, null: false, index: true
      t.references :declarable, polymorphic: true, index: true
      t.timestamps
    end
  end
end
