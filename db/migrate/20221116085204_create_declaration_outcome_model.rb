# frozen_string_literal: true

class CreateDeclarationOutcomeModel < ActiveRecord::Migration[6.1]
  def change
    create_table :participant_declaration_outcomes do |t|
      t.string :state, null: false
      t.date :completion_date, null: false
      t.references :participant_declaration, null: false, foreign_key: { column: :declaration_id }, type: :uuid, index: { name: "index_declaration" }

      t.timestamps
    end
  end
end
