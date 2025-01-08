# frozen_string_literal: true

class DropTableNPQApplicationExports < ActiveRecord::Migration[7.1]
  def up
    drop_table :npq_application_exports
  end

  def down
    create_table :npq_application_exports, id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.uuid :user_id, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.index :user_id, name: "index_npq_application_exports_on_user_id"
    end
  end
end
