# frozen_string_literal: true

class CreateValidationErrors < ActiveRecord::Migration[7.0]
  def change
    create_table :validation_errors do |t|
      t.string "form_object", null: false
      t.uuid "user_id"
      t.string "request_path", null: false
      t.jsonb "details"
      t.index ["form_object"], name: "index_validation_errors_on_form_object"
      t.timestamps
    end
  end
end
