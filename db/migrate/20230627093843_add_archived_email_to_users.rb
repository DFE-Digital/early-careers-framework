# frozen_string_literal: true

class AddArchivedEmailToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :archived_email, :string
  end
end
