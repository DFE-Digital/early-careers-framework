# frozen_string_literal: true

class CreateSchoolMentors < ActiveRecord::Migration[6.1]
  def change
    create_table :school_mentors do |t|
      t.references :participant_profile, null: false, foreign_key: true, type: :uuid
      t.references :school, null: false, foreign_key: true, type: :uuid
      t.references :preferred_identity, references: :participant_identities, null: false, type: :uuid, foreign_key: { to_table: :participant_identities }
      t.timestamps
    end

    add_index :school_mentors, %i[participant_profile_id school_id], unique: true
  end
end
