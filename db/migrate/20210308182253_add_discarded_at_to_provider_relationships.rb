# frozen_string_literal: true

class AddDiscardedAtToProviderRelationships < ActiveRecord::Migration[6.1]
  def change
    add_column :provider_relationships, :discarded_at, :datetime
    add_index :provider_relationships, :discarded_at
  end
end
