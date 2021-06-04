# frozen_string_literal: true

class CreateParticipantDeclarations < ActiveRecord::Migration[6.1]
  def change
    create_table :participant_declarations do |t|
      t.references :lead_provider, null: false, foreign_key: true
      t.references :early_career_teacher_profile, null: false, foreign_key: true, index: { name: :participant_declarations_ect_profile_id }
      t.string :declaration_type
      t.datetime :declaration_date
      t.jsonb :raw_event
      t.timestamps
    end
  end
end
