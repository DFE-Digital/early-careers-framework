# frozen_string_literal: true

class AddDiscardedAtToDeliveryPartners < ActiveRecord::Migration[6.1]
  def change
    add_column :delivery_partners, :discarded_at, :datetime
    add_index :delivery_partners, :discarded_at
  end
end
