class AddDupeTargetedDeliveryFlag < ActiveRecord::Migration[6.1]
  def change
    add_column :applications, :targeted_delivery_funding_eligibility, :boolean, default: false
  end
end
