class AddPrimaryEstablishmentToApplication < ActiveRecord::Migration[6.1]
  def change
    add_column :applications, :primary_establishment, :boolean, default: false
  end
end
