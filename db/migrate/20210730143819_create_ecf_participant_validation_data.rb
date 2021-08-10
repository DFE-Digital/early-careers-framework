# frozen_string_literal: true

class CreateECFParticipantValidationData < ActiveRecord::Migration[6.1]
  def change
    create_table :ecf_participant_validation_data, id: :uuid do |t|
      t.references :participant_profile, foreign_key: true, index: { unique: true }
      t.string :full_name
      t.date :date_of_birth
      t.string :trn
      t.string :nino
      t.boolean :api_failure, default: false

      t.timestamps
    end
  end
end
