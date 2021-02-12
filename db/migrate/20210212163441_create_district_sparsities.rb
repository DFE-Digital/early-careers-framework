# frozen_string_literal: true

class CreateDistrictSparsities < ActiveRecord::Migration[6.1]
  def change
    create_table :district_sparsities do |t|
      t.references :local_authority_district, null: false, foreign_key: true, type: :uuid
      t.integer :start_year, limit: 2, null: false
      t.integer :end_year, limit: 2

      t.timestamps
    end
  end
end
