# frozen_string_literal: true

class CreateNPQApplicationExports < ActiveRecord::Migration[6.1]
  def change
    create_table :npq_application_exports do |t|
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
