# frozen_string_literal: true

class AddDeliveryPartnerToCsvUpload < ActiveRecord::Migration[6.1]
  def change
    add_reference :partnership_csv_uploads, :delivery_partner, index: true
  end
end
