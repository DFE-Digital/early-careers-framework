class DropUnusedColumnFlipperAdminAccess < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :flipper_admin_access, :boolean
  end
end
