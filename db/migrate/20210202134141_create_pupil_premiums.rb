# frozen_string_literal: true

class CreatePupilPremiums < ActiveRecord::Migration[6.1]
  def change
    create_table :pupil_premiums do |t|
      t.references :school, null: false, foreign_key: true, type: :uuid
      t.integer :start_year, limit: 2, null: false
      t.integer :total_pupils, null: false
      t.integer :eligible_pupils, null: false

      t.timestamps
    end
  end
end
