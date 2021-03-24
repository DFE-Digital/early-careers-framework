# frozen_string_literal: true

class ChangeItemIdTypeToUuid < ActiveRecord::Migration[6.1]
  def change
    remove_column :versions, :item_id, :bigint
    remove_index :versions, column: %i[item_type item_id], if_exists: true
    add_column :versions, :item_id, :uuid, null: false
    add_index :versions, %i[item_type item_id]
  end
end
