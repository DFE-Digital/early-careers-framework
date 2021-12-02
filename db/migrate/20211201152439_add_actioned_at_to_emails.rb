class AddActionedAtToEmails < ActiveRecord::Migration[6.1]
  def change
    add_column :emails, :actioned_at, :datetime
  end
end
