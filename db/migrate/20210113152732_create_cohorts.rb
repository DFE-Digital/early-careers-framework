# frozen_string_literal: true

class CreateCohorts < ActiveRecord::Migration[6.1]
  def change
    create_table :cohorts, id: :uuid do |t|
      t.timestamps
      t.column :start_year, :integer, limit: 2, null: false
    end
  end
end
