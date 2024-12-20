# frozen_string_literal: true

class CreateDeliveryPartnerProfiles2 < ActiveRecord::Migration[6.1]
  def change
    create_table :delivery_partner_profiles do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :delivery_partner, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
