# frozen_string_literal: true

class AddArchivedAtToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :archived_at, :datetime
  end
end
