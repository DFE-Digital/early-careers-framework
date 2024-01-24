# frozen_string_literal: true

class CreateEmailSchedules < ActiveRecord::Migration[7.0]
  def change
    create_table :email_schedules do |t|
      t.string :mailer_name, null: false
      t.date :scheduled_at, null: false
      t.string :status, null: false, default: "queued"
      t.integer :actual_email_count
      t.integer :failed_email_count
      t.timestamps
    end
  end
end
