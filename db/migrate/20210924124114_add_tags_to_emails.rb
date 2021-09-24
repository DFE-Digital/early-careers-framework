# frozen_string_literal: true

class AddTagsToEmails < ActiveRecord::Migration[6.1]
  def change
    add_column :emails, :tags, :string, array: true, null: false, default: []
  end
end
