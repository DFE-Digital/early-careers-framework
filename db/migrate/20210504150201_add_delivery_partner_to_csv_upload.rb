# frozen_string_literal: true

class AddDeliveryPartnerToCsvUpload < ActiveRecord::Migration[6.1]
  # rubocop:disable Rails/NotNullColumn
  def change
    add_reference :partnership_csv_uploads, :delivery_partner, index: true, null: false
  end
  # rubocop:enable Rails/NotNullColumn
end
