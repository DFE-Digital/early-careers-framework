class CreateIttProviders < ActiveRecord::Migration[6.1]
  def change
    create_table :itt_providers do |t|
      t.text :legal_name, unique: true
      t.text :operating_name
      t.date :removed_at

      t.boolean :approved

      t.timestamps
    end

    add_index :itt_providers, :legal_name, unique: true
  end
end
