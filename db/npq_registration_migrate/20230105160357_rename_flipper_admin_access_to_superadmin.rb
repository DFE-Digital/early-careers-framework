class RenameFlipperAdminAccessToSuperadmin < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :super_admin, :boolean, default: false, null: false

    User.where(flipper_admin_access: true).update_all(super_admin: true)
  end
end
