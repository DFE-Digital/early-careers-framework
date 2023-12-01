class AddUpdatedFromTraAtToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :updated_from_tra_at, :datetime
  end
end
