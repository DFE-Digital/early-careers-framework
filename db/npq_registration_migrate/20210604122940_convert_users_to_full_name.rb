class ConvertUsersToFullName < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :first_name, :full_name
    remove_column :users, :last_name, :text
  end
end
