class AddNetworkToSchools < ActiveRecord::Migration[6.0]
  def change
    add_reference :schools, :network, null: true, foreign_key: true, type: :uuid
  end
end
