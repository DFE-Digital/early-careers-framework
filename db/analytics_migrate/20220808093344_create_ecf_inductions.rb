# frozen_string_literal: true

class CreateECFInductions < ActiveRecord::Migration[6.1]
  def change
    create_table :ecf_inductions do |t|
      t.uuid :induction_record_id
      t.string :external_id
      t.uuid :participant_profile_id
      t.uuid :induction_programme_id
      t.string :induction_programme_type
      t.string :school_name
      t.string :school_urn
      t.string :schedule_id
      t.uuid :mentor_id
      t.uuid :appropriate_body_id
      t.string :appropriate_body_name
      t.datetime :start_date
      t.datetime :end_date
      t.string :induction_status
      t.string :training_status
      t.boolean :school_transfer
      t.timestamps
    end

    add_index :ecf_inductions, :induction_record_id, unique: true
  end
end
