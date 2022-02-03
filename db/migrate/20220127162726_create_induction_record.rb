# frozen_string_literal: true

class CreateInductionRecord < ActiveRecord::Migration[6.1]
  def change
    create_table :induction_records do |t|
      t.references :induction_programme, null: false, foreign_key: true, type: :uuid
      t.references :participant_profile, null: false, foreign_key: true, type: :uuid
      t.references :schedule, null: false, foreign_key: true, type: :uuid
      t.string :status, null: false, default: "active", index: true
      t.datetime :start_date, null: false
      t.datetime :end_date, null: true
      t.timestamps
    end
  end
end
