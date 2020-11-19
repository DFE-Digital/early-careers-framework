class CreateSchools < ActiveRecord::Migration[6.0]
  def change
    create_table :schools do |t|
      t.timestamps
      t.column :name, :string, null: false
      t.column :opened_at, :date
      t.column :school_type, :string
    end
  end
end
