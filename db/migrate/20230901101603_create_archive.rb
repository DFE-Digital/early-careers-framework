# frozen_string_literal: true

class CreateArchive < ActiveRecord::Migration[7.0]
  def change
    create_table :archives do |t|
      t.string :object_type, null: false, index: true
      t.string :object_id, null: false, index: true
      t.string :reason, null: false, index: true
      t.jsonb :data
      t.timestamps
    end

    add_index :archives, "(data->'meta')", using: :gin, name: "index_archives_on_data_meta"
  end
end
