# frozen_string_literal: true

class AddNotifyFieldsToNominationEmail < ActiveRecord::Migration[6.1]
  def change
    change_table :nomination_emails, bulk: true do
      add_column :nomination_emails, :notify_id, :string
      add_column :nomination_emails, :delivered_at, :datetime
    end

    add_index :nomination_emails, :notify_id
  end
end
