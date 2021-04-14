# frozen_string_literal: true

class CreatePartnershipNotificationEmails < ActiveRecord::Migration[6.1]
  def change
    create_table :partnership_notification_emails do |t|
      t.string :token, null: false
      t.string :sent_to, null: false
      t.string :notify_id
      t.string :notify_status
      t.datetime :delivered_at

      t.references :partnership, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
    add_index :partnership_notification_emails, :token, unique: true
  end
end
