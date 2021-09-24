class AddStatusToEmails < ActiveRecord::Migration[6.1]
  def change
    add_column :emails, :status, :string, null: false, default: "submitted"
    add_column :emails, :delivered_at, :datetime
  end
end
