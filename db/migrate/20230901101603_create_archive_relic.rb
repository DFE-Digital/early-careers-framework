# frozen_string_literal: true

class CreateArchiveRelic < ActiveRecord::Migration[7.0]
  def change
    create_table :archive_relics do |t|
      t.string :object_type, null: false, index: true
      t.string :object_id, null: false, index: true
      t.string :display_name, null: false, index: true
      t.string :reason, null: false, index: true
      t.jsonb :data
      t.timestamps
    end

    add_index :archive_relics, "(data->'meta')", using: :gin, name: "index_archive_relics_on_data_meta"
  end
end
