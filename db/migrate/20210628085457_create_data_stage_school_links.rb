# frozen_string_literal: true

class CreateDataStageSchoolLinks < ActiveRecord::Migration[6.1]
  def change
    create_table :data_stage_school_links, id: :uuid do |t|
      t.references :data_stage_school, null: false, foreign_key: true, type: :uuid
      t.string :link_urn, null: false
      t.string :link_type, null: false
      t.timestamps
    end

    add_index :data_stage_school_links, %i[data_stage_school_id link_urn], unique: true, name: "data_stage_school_links_uniq_idx"
  end
end
