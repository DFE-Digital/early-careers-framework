class CreateLeadProviders < ActiveRecord::Migration[6.1]
  def change
    create_table :lead_providers do |t|
      t.text :name, null: false

      t.timestamps
    end
  end
end
