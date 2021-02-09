# frozen_string_literal: true

class CreateDeliveryPartners < ActiveRecord::Migration[6.1]
  def change
    create_table :delivery_partners, id: :uuid do |t|
      t.timestamps
      t.column :name, :string, null: false
    end
  end
end
