class CreateNetworks < ActiveRecord::Migration[6.0]
  def change
    create_table :networks do |t|
      t.timestamps
      t.column :name, :string, null: false
    end
  end
end
