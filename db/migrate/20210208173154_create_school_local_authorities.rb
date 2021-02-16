# frozen_string_literal: true

class CreateSchoolLocalAuthorities < ActiveRecord::Migration[6.1]
  def change
    create_table :school_local_authorities do |t|
      t.references :school, null: false, foreign_key: true, type: :uuid
      t.references :local_authority, null: false, foreign_key: true, type: :uuid
      t.integer :start_year, limit: 2, null: false
      t.integer :end_year, limit: 2

      t.timestamps
    end
  end
end
