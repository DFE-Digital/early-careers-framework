# frozen_string_literal: true

class AddDeliveryPartnerToPartnership < ActiveRecord::Migration[6.1]
  def change
    add_reference :partnerships, :delivery_partner, null: true, foreign_key: true, type: :uuid
  end
end
