# frozen_string_literal: true

class CreateSchoolCohorts < ActiveRecord::Migration[6.1]
  def change
    create_table :school_cohorts, id: :uuid do |t|
      t.string :induction_programme_status, null: false, default: :not_yet_known
      t.references :school, null: false, foreign_key: true, type: :uuid
      t.references :cohort, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
