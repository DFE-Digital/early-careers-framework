# frozen_string_literal: true

class CreateParticipantIdentity < ActiveRecord::Migration[6.1]
  def change
    create_table :participant_identities do |t|
      t.references :user, null: false, foreign_key: true
      t.string :email, null: false
      t.uuid :external_identifier, null: false
      t.string :origin, null: false, default: "ecf"
      t.timestamps
    end

    add_index :participant_identities, :email, unique: true
    add_index :participant_identities, :external_identifier, unique: true
  end
end
