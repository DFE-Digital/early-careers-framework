# frozen_string_literal: true

class CreateDeletedDuplicates < ActiveRecord::Migration[6.1]
  def change
    create_table :deleted_duplicates do |t|
      t.jsonb :data
      t.references :primary_participant_profile, null: false, foreign_key: { to_table: :participant_profiles }, type: :uuid

      t.timestamps
    end
  end
end
