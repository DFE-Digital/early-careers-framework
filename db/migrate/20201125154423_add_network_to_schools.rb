class AddNetworkToSchools < ActiveRecord::Migration[6.0]
  def change
    add_reference :schools, :network, null: true, foreign_key: true
  end
end
