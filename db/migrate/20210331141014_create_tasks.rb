# frozen_string_literal: true

class CreateTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :tasks, id: :uuid do |t|
      t.string :name, null: false
      t.string :status, null: false, default: "TO DO"
      t.string :description, null: false
      t.references :school_cohort, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
