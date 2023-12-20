class AddFlipperAdminToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :flipper_admin_access, :boolean, default: false
  end
end
