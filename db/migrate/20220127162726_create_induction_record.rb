# frozen_string_literal: true

class CreateInductionRecord < ActiveRecord::Migration[6.1]
  def change
    create_table :induction_records do |t|
      t.references :induction_programme, null: false, foreign_key: true, type: :uuid
      t.references :participant_profile, null: false, foreign_key: true, type: :uuid
      t.references :schedule, null: false, foreign_key: true, type: :uuid
      t.datetime :start_date, null: false
      t.timestamps
    end
  end
end
