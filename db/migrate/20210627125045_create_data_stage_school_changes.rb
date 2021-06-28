# frozen_string_literal: true

class CreateDataStageSchoolChanges < ActiveRecord::Migration[6.1]
  def change
    create_table :data_stage_school_changes, id: :uuid do |t|
      t.references :data_stage_school, null: false, foreign_key: true, type: :uuid
      t.json :attribute_changes
      t.string :status, null: false, default: "changed"
      t.boolean :handled, null: false, default: false
      t.timestamps
    end

    add_index :data_stage_school_changes, :status
  end
end
