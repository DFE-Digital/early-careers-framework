class DropUniqueIndexFromUsersEcfId < ActiveRecord::Migration[6.1]
  def change
    remove_index :users, :ecf_id, unique: true
    add_index :users, :ecf_id
  end
end
