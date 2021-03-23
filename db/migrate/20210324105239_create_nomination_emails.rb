# frozen_string_literal: true

class CreateNominationEmails < ActiveRecord::Migration[6.1]
  def change
    create_table :nomination_emails, id: :uuid do |t|
      t.string     :token, null: false
      t.string     :notify_status
      t.string     :sent_to, null: false
      t.datetime   :sent_at
      t.datetime   :opened_at
      t.references :school, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
    add_index :nomination_emails, :token, unique: true
  end
end
