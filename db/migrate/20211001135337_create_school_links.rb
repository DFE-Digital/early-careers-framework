# frozen_string_literal: true

class CreateSchoolLinks < ActiveRecord::Migration[6.1]
  def change
    create_table :school_links do |t|
      t.references :school
      t.references :link_school, foreign_key: { to_table: 'schools' }
      t.string :link_type, null: false
      t.string :link_reason, null: false, default: "simple"
      t.timestamps
    end
  end
end
