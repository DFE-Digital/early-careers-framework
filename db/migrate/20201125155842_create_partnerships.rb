class CreatePartnerships < ActiveRecord::Migration[6.0]
  def change
    create_table :partnerships do |t|
      t.timestamps
      t.references :school, null: false, foreign_key: true
      t.references :lead_provider, null: false, foreign_key: true
      t.column :confirmed_at, :datetime
    end
  end
end
