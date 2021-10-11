# frozen_string_literal: true

class CreateParticipantDeclarationStates < ActiveRecord::Migration[6.1]
  def change
    create_table :declaration_states do |t|
      t.references :participant_declaration
      t.string :state, null: false, default: "submitted"
      t.timestamps
    end
  end
end
