# frozen_string_literal: true

class CreateParticipantDeclarationAttempts < ActiveRecord::Migration[6.1]
  def change
    create_table :participant_declaration_attempts do |t|
      t.string :declaration_type
      t.datetime :declaration_date
      t.uuid :user_id
      t.string :course_identifier
      t.string :evidence_held
      t.uuid :cpd_lead_provider_id

      t.timestamps
    end
  end
end
