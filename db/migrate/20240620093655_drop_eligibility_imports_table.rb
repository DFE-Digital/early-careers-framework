# frozen_string_literal: true

class DropEligibilityImportsTable < ActiveRecord::Migration[7.1]
  def up
    drop_table "npq_application_eligibility_imports"
  end

  def down
    create_table "npq_application_eligibility_imports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.uuid "user_id", null: false
      t.string "filename"
      t.string "status", default: "pending"
      t.integer "updated_records"
      t.jsonb "import_errors", default: []
      t.datetime "processed_at", precision: nil
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["user_id"], name: "index_npq_application_eligibility_imports_on_user_id"
    end
  end
end
