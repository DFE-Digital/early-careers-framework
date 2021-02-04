# frozen_string_literal: true

class CreatePupilPremiumEligibilities < ActiveRecord::Migration[6.1]
  def change
    create_table :pupil_premium_eligibilities do |t|
      t.references :school, null: false, foreign_key: true, type: :uuid
      t.column :start_year, :integer, limit: 2, null: false
      t.float :percent_primary_pupils_eligible, null: false
      t.float :percent_secondary_pupils_eligible, null: false

      t.timestamps
    end
  end
end
