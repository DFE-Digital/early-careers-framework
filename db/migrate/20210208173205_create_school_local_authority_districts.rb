# frozen_string_literal: true

class CreateSchoolLocalAuthorityDistricts < ActiveRecord::Migration[6.1]
  def change
    create_table :school_local_authority_districts do |t|
      t.references :school, null: false, foreign_key: true, type: :uuid
      t.references :local_authority_district, null: false, foreign_key: true, type: :uuid, index: { name: "index_schools_lads_on_lad_id" }
      t.integer :start_year, limit: 2, null: false
      t.integer :end_year, limit: 2

      t.timestamps
    end
  end
end
