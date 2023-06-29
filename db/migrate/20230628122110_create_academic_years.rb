# frozen_string_literal: true

class CreateAcademicYears < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    create_table :academic_years, id: :string do |t|
      t.column :previous_id, :string, limit: 7, null: true
      t.column :start_year, :int
      t.column :end_year, :int
      t.column :start_date, :datetime

      t.column :ecf_early_rollout_year, :boolean, default: false

      t.references :cohort, foreign_key: true, index: true, null: true, type: :uuid

      t.index :id, unique: true
      t.index :start_year, unique: true
      t.index :end_year, unique: true
      t.index :start_date, unique: true
      t.index :previous_id, unique: true

      t.timestamps
    end

    add_foreign_key :academic_years, :academic_years, column: :previous_id, validate: false

    validate_foreign_key :academic_years, :academic_years
  end
end
