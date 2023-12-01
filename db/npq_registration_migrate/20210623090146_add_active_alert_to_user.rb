class AddActiveAlertToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :active_alert, :boolean, default: false
  end
end
