# frozen_string_literal: true

class DropDeliveryPartnerProfiles < ActiveRecord::Migration[6.1]
  def change
    drop_table :delivery_partner_profiles do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :delivery_partner, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
