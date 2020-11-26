class CreateLeadProviders < ActiveRecord::Migration[6.0]
  def change
    create_table :lead_providers, id: :uuid do |t|
      t.timestamps
      t.column :name, :string, null: false
    end
  end
end
